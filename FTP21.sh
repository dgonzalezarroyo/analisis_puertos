#!/bin/bash

#Echo por Ulyses Huete

BASE_NET="10.225.255"
START=128
END=254

USER="usuario"
PASS="password"

OUT="ftp_audit_$(date +%F_%H%M).txt"

echo "Auditando FTP en rango $BASE_NET.$START-$END" > "$OUT"

check_host() {
    IP=$1

    nc -z -w2 $IP 21 >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "$IP;NO_FTP"
        return
    fi

    RESP=$(curl -s --connect-timeout 3 ftp://$USER:$PASS@$IP/ 2>&1)

    echo "$RESP" | grep -q "230" && echo "$IP;LOGIN_OK" && return
    echo "$RESP" | grep -qi "530" && echo "$IP;BAD_CREDS" && return

    echo "$IP;UNKNOWN"
}

export -f check_host
export USER PASS BASE_NET

# Ejecutar y guardar TODO directamente en el OUT
RESULTS=$(seq $START $END | xargs -I{} -P 10 bash -c '
    check_host "'"$BASE_NET"'.{}"
')

# Escribir ordenado en un solo archivo
echo "$RESULTS" | sort -t '.' -k1,1n -k2,2n -k3,3n -k4,4n >> "$OUT"

echo "" >> "$OUT"
echo "=========" >> "$OUT"
echo "LOGIN_OK:" >> "$OUT"
echo "$RESULTS" | grep "LOGIN_OK" >> "$OUT"

echo "" >> "$OUT"
echo "=========" >> "$OUT"
echo "Resumen:" >> "$OUT"
echo "$RESULTS" | wc -l | awk '{print "TOTAL:", $1}' >> "$OUT"
echo "$RESULTS" | grep -c LOGIN_OK | awk '{print "LOGIN_OK:", $1}' >> "$OUT"
echo "$RESULTS" | grep -c BAD_CREDS | awk '{print "BAD_CREDS:", $1}' >> "$OUT"
echo "$RESULTS" | grep -c UNKNOWN | awk '{print "UNKNOWN:", $1}' >> "$OUT"
echo "$RESULTS" | grep -c NO_FTP | awk '{print "NO_FTP:", $1}' >> "$OUT"

echo "Finalizado. Resultados en $OUT"

echo "======================" >> "$OUT"
echo "INFO FTP" >> "$OUT"
echo "usar este comando para ver el ftp de equipos especificos." >> "$OUT"
echo "El usuario y password van en el mismo comando." >> "$OUT"
echo 'curl -u usuario:password ftp://IP/' >> "$OUT"
echo "======================" >> "$OUT"
echo "" >> "$OUT"
