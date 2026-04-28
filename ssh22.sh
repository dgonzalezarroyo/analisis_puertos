#!/bin/bash

#Echo por Ulyses Huete

BASE_NET="10.225.255"
START=128
END=254

USER="usuario"
PASS="password"

OUT="ssh_audit_$(date +%F_%H%M).txt"

echo "Auditando SSH en rango $BASE_NET.$START-$END" > "$OUT"

check_host() {
    IP=$1

    nc -z -w2 $IP 22 >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "$IP;NO_SSH"
        return
    fi

    # intento de login no interactivo
    RESP=$(sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3 $USER@$IP "echo OK" 2>&1)

    echo "$RESP" | grep -q "OK" && echo "$IP;LOGIN_OK" && return
    echo "$RESP" | grep -i "Permission denied" && echo "$IP;BAD_CREDS" && return

    echo "$IP;UNKNOWN"
}

export -f check_host
export USER PASS BASE_NET

RESULTS=$(seq $START $END | xargs -I{} -P 10 bash -c '
    check_host "'"$BASE_NET"'.{}"
')

echo "$RESULTS" > "$OUT"

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
echo "$RESULTS" | grep -c NO_SSH | awk '{print "NO_SSH:", $1}' >> "$OUT"

echo "Finalizado. Resultados en $OUT"

echo "======================" >> "$OUT"
echo "INFO SSH" >> "$OUT"
echo "usar este comando para ver el ssh de equipos especificos." >> "$OUT"
echo "El password va entre comillas en el comando." >> "$OUT"
echo 'sshpass -p "password" ssh usuario@IP' >> "$OUT"
echo "======================" >> "$OUT"
echo "" >> "$OUT"
