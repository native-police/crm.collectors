$results = @()
#$city=Read-Host "Please enter city you wish (RU)/Пожалуйста введите город(RU)"
$department="Отдел коммерции"
$users = Get-ADUser -SearchBase "OU=$department,OU=Пользователи,OU=Челябинск,OU=Cities,DC=2gis,DC=local"  -Properties memberof -Filter * 
foreach ($user in $users) {
    $groups = $user.memberof -join ';'
    $results += New-Object psObject -Property @{'User'=$user.name;'Groups'= $groups}
    }
$results | Where-Object { $_.groups -notmatch 'crm.collectorgroup' } | Select-Object user

#Костыль, ну а что поделать?
$results2 = @()
$department2="Сервис менеджеры"
$users = Get-ADUser -SearchBase "OU=$department2,OU=Пользователи,OU=Челябинск,OU=Cities,DC=2gis,DC=local"  -Properties memberof -Filter * 
foreach ($user in $users) {
    $groups = $user.memberof -join ';'
    $results2 += New-Object psObject -Property @{'User'=$user.name;'Groups'= $groups}
    }
$results2 | Where-Object { $_.groups -notmatch 'crm.collectorgroup' } | Select-Object user