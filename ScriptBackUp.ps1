#Este es un Scripts para buscar y subir un backup a mysql.
#Prog: CrossDev april-08-2022
#Declaramos variables con Anio, mes y dia para buscar la ruta del backup.
Write-Host "-------------------------------------------------------------------------------";
Write-Host "Copiando archivo.....";
Write-Host "-------------------------------------------------------------------------------";
$anio=Get-Date -Format yyyy
$mes=Get-Date -Format MM
$dia=Get-Date -Format dd
#Copiamos el backup del servidor en el directorio desde donde subiremos el backup. 
Copy-Item -Path "\\data-server\disk\$anio\$mes\$dia\MyBackup.rar" -Destination C:\Users\$env:UserName\Desktop\
Write-Host "Archivo Copiado!!";
Write-Host "-------------------------------------------------------------------------------";
#descomprimimos el archivo MyBackup.rar
& "C:\Program Files\WinRAR\UnRAR.exe" e -y C:\Users\$env:UserName\Desktop\MyBackup.rar C:\Users\$env:UserName\Desktop\
#Solo acepta archivos .zip
#Expand-Archive -LiteralPath C:\Users\$env:UserName\Desktop\MyBackup.rar  -DestinationPath C:\Users\$env:UserName\Desktop\
Write-Host "Archivo Descomprimido.!";
Write-Host "-------------------------------------------------------------------------------";
Write-Host "Subiendo Backup....."
Write-Host "-------------------------------------------------------------------------------";
#Subimos el Backup.
&cmd /c "mysql -u root -pmysql db < C:\Users\$env:UserName\Desktop\MyBackup.sql"
Write-Host "Backup Realizado.!";
Write-Host "-------------------------------------------------------------------------------";
#Eliminamos el MyBackup.rar y Mybackup.sql
Remove-Item C:\Users\$env:UserName\Desktop\MyBackup.rar, C:\Users\$env:UserName\Desktop\MyBackup.sql
#Guardamos en una variable el query de mysql, el cual se convierte en arreglo. 
$sql = mysql -uroot -pmysql -e "SELECT max(Column) FROM db.table;"
#Guardamos en una variable la fecha actual.
$fecha = Get-Date -Format "yyyy-MM-dd";
$msg = "La Fecha del ultimo Backup es:  "
$subject = "";

#Buscamos el disco donde estan guardado el backup.
#Y Obtenemos el espacio disponible del mismo y el tamaño.
#Guardamos la salida en una variable declarando el espacio libre y el tamaño del disk.
$diskD = ([wmi]"\\PcName\root\cimv2:Win32_logicalDisk.DeviceID='D:'")
$d = "`n El Disco Kington(D) tiene {0:#.0} GB free of {1:#.0} GB Total. " -f ($diskD.FreeSpace/1GB),($diskD.Size/1GB)



#Comprobamos que las fecha del backup y la fecha actual coinciden
#para asi cambiar el Subject
if ($sql[1] -eq $fecha){
    $subject = "(BIEN) Backup de DB restaurado correctamente.";
}
else{
    $subject = "(MAL)Backup de DB - necesita revision";
 }

#Creamos el cuerpo del mensaje que vamos a enviar.
$message = new-object Net.Mail.MailMessage;
$message.From = "soporte@mail.com";
$message.To.Add("hola@mail.com");
$message.Subject = $subject;
$message.Body = $msg + $sql[1] + $d;
$smtp = new-object Net.Mail.SmtpClient("mail.mail.com", "587");
$smtp.EnableSSL = $true;
$smtp.Credentials = New-Object System.Net.NetworkCredential("soporte@mail.com", "Password");
$smtp.send($message);
write-host "Mail Enviado..!!";

#Creamos la funciones para la notificacion del sistema
[reflection.assembly]::loadwithpartialname('System.Windows.Forms')
[reflection.assembly]::loadwithpartialname('System.Drawing')
$notify = new-object system.windows.forms.notifyicon
$notify.icon = [System.Drawing.SystemIcons]::Information
$notify.visible = $true
$notify.showballoontip(10,'BACKUP DATABASE','El Backup de la base de dato sea realizado.! ',[system.windows.forms.tooltipicon]::None)