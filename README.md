Echo por Ulyses Huete

AUDITORIA FTP EN RED LOCAL

Este script realiza una auditoría automática de servidores FTP dentro de un rango de direcciones IP. Su propósito es identificar qué equipos tienen el puerto FTP abierto y comprobar si las credenciales proporcionadas permiten iniciar sesión correctamente.
1. ¿Qué hace el script?

    Escanea un rango de IPs definido por:

        BASE_NET (ej. 10.225.255)

        START y END (ej. 128–254)

    Comprueba si el puerto 21 (FTP) está abierto usando nc (netcat).

    Si el puerto está abierto:

        Intenta conectarse mediante curl usando las credenciales configuradas (USER y PASS).

        Analiza la respuesta del servidor FTP:

            230 → LOGIN_OK (credenciales válidas)

            530 → BAD_CREDS (credenciales incorrectas)

            Cualquier otra respuesta → UNKNOWN (Tiene filtro aplicado)

    Registra todos los resultados en un archivo de salida con nombre:
    Código

    ftp_audit_YYYY-MM-DD_HHMM.txt

    Genera un resumen final con:

        Total de hosts analizados

        Hosts con login correcto

        Hosts con credenciales incorrectas

        Hosts sin FTP

        Hosts con respuesta desconocida

2. Ejecución en paralelo

El script usa xargs -P 10 para lanzar hasta 10 comprobaciones simultáneas, acelerando el proceso de auditoría.
3. Archivos generados

    ftp_audit_YYYY-MM-DD_HHMM.txt  
    Contiene:

        Resultados ordenados por IP

        Sección de LOGIN_OK

        Resumen estadístico

        Recordatorio del comando para probar FTP manualmente

4. Comando útil incluido en el informe

El informe final recuerda cómo probar manualmente un servidor FTP:
Código

curl -u usuario:password ftp://IP/

5. Requisitos

    bash

    nc (netcat)

    curl

    Permisos para ejecutar comandos de red




AUDITORIA SSH EN RED LOCAL

Este script realiza una auditoría automática de servidores SSH dentro de un rango de direcciones IP. Su objetivo es identificar qué equipos tienen el puerto SSH abierto y comprobar si las credenciales proporcionadas permiten iniciar sesión correctamente.
1. ¿Qué hace el script?

    Escanea un rango de IPs definido por:

        BASE_NET (ej. 10.225.255)

        START y END (ej. 128–254)

    Comprueba si el puerto 22 (SSH) está abierto usando nc (netcat).

    Si el puerto está abierto:

        Intenta un login SSH no interactivo usando sshpass con las credenciales configuradas (USER y PASS).

        Ejecuta un comando simple (echo OK) para verificar si la autenticación fue exitosa.

    Clasifica el resultado según la respuesta:

        LOGIN_OK → acceso SSH correcto

        BAD_CREDS → credenciales incorrectas

        UNKNOWN → respuesta inesperada (Tiene filtro aplicado)

        NO_SSH → puerto 22 cerrado o sin servicio SSH

    Guarda todos los resultados en un archivo de salida:
    Código

    ssh_audit_YYYY-MM-DD_HHMM.txt

    Genera un resumen final con:

        Total de hosts analizados

        Hosts con login correcto

        Hosts con credenciales incorrectas

        Hosts sin SSH

        Hosts con respuesta desconocida

2. Ejecución en paralelo

El script usa xargs -P 10 para ejecutar hasta 10 comprobaciones simultáneas, acelerando significativamente la auditoría del rango de IPs.
3. Archivos generados

    ssh_audit_YYYY-MM-DD_HHMM.txt  
    Contiene:

        Resultados completos

        Sección de LOGIN_OK

        Resumen estadístico

        Recordatorio del comando para probar SSH manualmente

4. Comando útil incluido en el informe

El informe final recuerda cómo probar manualmente un acceso SSH:
Código

sshpass -p "password" ssh usuario@IP

5. Requisitos

    bash

    nc (netcat)

    sshpass

    ssh

    Permisos para ejecutar comandos de red


AUDITORIA SMB EN RED LOCAL

Este script realiza una auditoría automática de servicios SMB dentro de un rango de direcciones IP. Su objetivo es identificar qué equipos tienen SMB activo, clasificarlos según el tipo de recurso compartido y comprobar si las credenciales proporcionadas permiten un acceso real.
1. ¿Qué hace el script?

    Escanea un rango de IPs definido por:

        BASE_NET (ej. 10.225.255)

        START y END (ej. 128–254)

    Comprueba si el puerto SMB (445) está abierto en cada host.

    Si SMB está activo:

        Ejecuta smbclient -L para listar los recursos compartidos.

        Clasifica el equipo según lo que encuentre:

            IMPRESORA

            SERVIDOR_IMPRESION

            SERVIDOR_FICHEROS

            PC_O_SERVICIO

            UNKNOWN (Tiene filtro aplicado)

    Intenta un login real usando las credenciales configuradas (USER y PASS):

        Si el login funciona, guarda la IP en un archivo temporal.

    Genera un informe completo con:

        Resultados del escaneo

        Equipos con acceso real (login OK)

        Resumen estadístico

        Recordatorio del comando para revisar manualmente un equipo

2. Archivos generados

    smb_audit_YYYY-MM-DD_HHMM.txt  
    Contiene todo el informe de la auditoría.

    /tmp/smb_ok_PID  
    Lista temporal de IPs donde el login SMB fue exitoso.

3. Ejecución en paralelo

El script usa xargs -P 10 para lanzar hasta 10 comprobaciones simultáneas, acelerando el escaneo del rango de IPs.
4. Comando útil incluido en el informe

El informe final recuerda cómo consultar manualmente un equipo SMB:
Código

smbclient -L //IP -U "user%password"

5. Requisitos

    bash

    nc (netcat)

    smbclient

    Permisos para ejecutar comandos de red
