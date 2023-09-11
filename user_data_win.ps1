<powershell>
$username = "vagrant"
$password = ConvertTo-SecureString "password" -AsPlainText -Force
New-LocalUser -Name "$username" -Password $password -FullName "$username" -Description "ansible user"
</powershell>
