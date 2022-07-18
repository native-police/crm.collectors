Import-Module ActiveDirectory

$results = @()

$departments = "Отдел коммерции", "Сервис менеджеры"
foreach ($department in $departments)
{
$users = Get-ADUser -SearchBase "OU=$department,OU=Пользователи,OU=Челябинск,OU=Cities,DC=2gis,DC=local"  -Property memberof -Filter * 
foreach ($user in $users) {
    $groups = $user.memberof -join ';'
    $results += New-Object psObject -Property @{'User'=$user.samaccountname;'Username'=$user.name;'Groups'= $groups}
    }
$results | Where-Object { $_.groups -notmatch 'crm.collectorgroup' } | Select-Object user,name | export-csv -Append -NoTypeInformation -force -Encoding UTF8 -Path C:\Projects_etc\crm.collector\not_collectors.csv
}

$smtpserver = "owa.2gis.ru"
$from = "admin@chelyabinsk.2gis.ru"
$non_list = Import-Csv -Path C:\Projects_etc\crm.collector\not_collectors.csv
$encoding = [System.Text.Encoding]::UTF8
$plaintext = @"
Этих пользователей нет в crm.collectorgroup - оформляй заявку:
"@
$body_notification = Import-Csv C:\Projects_etc\crm.collector\not_collectors.csv | select user,name | Out-String
$sendto = "admin@chelyabinsk.2gis.ru"


if ($null -ne $non_list)
{ Send-MailMessage -to $sendto  -Subject "crm.collectorgroup"`
-Body $plaintext$body_notification -SmtpServer $smtpserver -From $from -Encoding $encoding }
else {
 }
Remove-Item "C:\Projects_etc\crm.collector\not_collectors.csv" #Удаление файла после отправки
