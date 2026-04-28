#!/bin/bash


#Echo por Ulyses Huete

BASE_NET="10.225.255"
START=128
END=254

USER="usuario"
PASS="password"

OUT="smb_audit_$(date +%F_%H%M).txt"
TMP_OK="/tmp/smb_ok_$$"

echo "AUDITORÍA SMB $BASE_NET.$START-$END" > "$OUT"
echo "" > "$TMP_OK"

check_host() {
    IP=$1

    # Comprobar SMB activo
    nc -z -w2 $IP 445 >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "$IP;NO_SMB"
        return
    fi

    SMB=$(smbclient -L //$IP -U "$USER%$PASS" -N 2>&1)

    # No hay acceso a listado
    echo "$SMB" | grep -qi "Sharename"
    if [ $? -ne 0 ]; then
        echo "$IP;SMB_SIN_ACCESO"
        return
    fi

    # =========================
    # Clasificación de tipo
    # =========================

    echo "$SMB" | grep -qi "Printer"
    if [ $? -eq 0 ]; then
        echo "$IP;IMPRESORA"
    elif echo "$SMB" | grep -qi "print\$"; then
        echo "$IP;SERVIDOR_IMPRESION"
    elif echo "$SMB" | grep -qiE "datos|users|home|backup|files"; then
        echo "$IP;SERVIDOR_FICHEROS"
    elif echo "$SMB" | grep -qi "IPC\$"; then
        echo "$IP;PC_O_SERVICIO"
    else
        echo "$IP;DESCONOCIDO"
    fi

    # =========================
    # Login real (acceso a shares)
    # =========================

    SMB2=$(smbclient //$IP -U "$USER%$PASS" -c "ls" 2>&1)

    echo "$SMB2" | grep -qi "NT_STATUS_LOGON_FAILURE"
    if [ $? -ne 0 ]; then
        echo "$IP" >> "$TMP_OK"
    fi
}

export -f check_host
export USER PASS BASE_NET TMP_OK

RESULTS=$(seq $START $END | xargs -I{} -P 10 bash -c '
    check_host "'"$BASE_NET"'.{}"
')

# =========================
# BLOQUE COMPLETO
# =========================
echo "$RESULTS" >> "$OUT"

# =========================
# SEPARADOR
# =========================
echo "" >> "$OUT"
echo "=========" >> "$OUT"
echo "EQUIPOS CON ACCESO REAL (LOGIN OK):" >> "$OUT"
cat "$TMP_OK" >> "$OUT"

# =========================
# RESUMEN
# =========================
echo "" >> "$OUT"
echo "=========" >> "$OUT"
echo "RESUMEN:" >> "$OUT"

echo "TOTAL: $(echo "$RESULTS" | wc -l)" >> "$OUT"
echo "IMPRESORAS: $(echo "$RESULTS" | grep -c IMPRESORA)" >> "$OUT"
echo "SERVIDORES IMPRESIÓN: $(echo "$RESULTS" | grep -c SERVIDOR_IMPRESION)" >> "$OUT"
echo "SERVIDORES FICHEROS: $(echo "$RESULTS" | grep -c SERVIDOR_FICHEROS)" >> "$OUT"
echo "PCS/SERVICIOS: $(echo "$RESULTS" | grep -c PC_O_SERVICIO)" >> "$OUT"
echo "LOGIN_OK_REAL: $(wc -l < "$TMP_OK")" >> "$OUT"

echo "======================" >> "$OUT"
echo "usar este comando para ver el samba de equipos especificos." >> "$OUT"
echo "El user%password va entre comillas en el comando." >> "$OUT"
echo "smbclient -L //IP -U user%password" >> "$OUT"
echo "======================" >> "$OUT"
echo "" >> "$OUT"

