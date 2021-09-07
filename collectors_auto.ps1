Import-Module ActiveDirectory

$results = @()
#$city=Read-Host "Please enter city you wish (RU)/Пожалуйста введите город(RU)"
$department="Отдел коммерции"
$users = Get-ADUser -SearchBase "OU=$department,OU=Пользователи,OU=Челябинск,OU=Cities,DC=2gis,DC=local"  -Property memberof -Filter * 
foreach ($user in $users) {
    $groups = $user.memberof -join ';'
    $results += New-Object psObject -Property @{'User'=$user.name;'Groups'= $groups}
    }

$results | Where-Object { $_.groups -notmatch 'crm.collectorgroup' } | Select-Object user | export-csv -Append -NoTypeInformation -force -Encoding UTF8 -Path C:\Projects_etc\crm.collector\not_collectors.csv

#Костыль, ну а что поделать?
$results2 = @()
$department2="Сервис менеджеры"
$users = Get-ADUser -SearchBase "OU=$department2,OU=Пользователи,OU=Челябинск,OU=Cities,DC=2gis,DC=local"  -Properties memberof -Filter * 
foreach ($user in $users) {
    $groups = $user.memberof -join ';'
    $results2 += New-Object psObject -Property @{'User'=$user.name;'Groups'= $groups}
    }
$results2 | Where-Object { $_.groups -notmatch 'crm.collectorgroup' } | Select-Object user | export-csv -Append -NoTypeInformation -force -Encoding UTF8 -Path C:\Projects_etc\crm.collector\not_collectors.csv



$smtpserver = "owa.2gis.ru"
$from = "admin@chelyabinsk.2gis.ru"
$users = Import-Csv -Path C:\Projects_etc\crm.collector\not_collectors.csv
$encoding = [System.Text.Encoding]::UTF8
$plaintext = @"
Этих пользователей нет в crm.collectorgroup - оформляй заявку:
"@
$body_notification = Import-Csv C:\Projects_etc\crm.collector\not_collectors.csv | select user | Out-String



$sendto = "admin@chelyabinsk.2gis.ru"


Send-MailMessage -to $sendto  -Subject "crm.collectorgroup"`
-Body $plaintext$body_notification -SmtpServer $smtpserver -From $from -Encoding $encoding


Remove-Item "C:\Projects_etc\crm.collector\not_collectors.csv" #Удаление файла после отправки
