# SubirBackupPS
Este Es un Scripts Escrito en PowerShell para subir un backup a mysql. 

El Scripts busca en el servidor un archivo, lo copiar en una direccion, lo descomprimirlo, sube el .sql a mysql, hacer un query a mysql de la ultima fecha, luego gradamos en una variable la fecha actual, luego compara estas dos fecha y envia un mensaje por correo, en el mensaje esta el asunto que dependiendo de la comparacion de la dos fecha puede cambiar, en el cuerpo esta la fecha del query ejecutado a mysql, luego hace una notificacion de sistema para el usuario
