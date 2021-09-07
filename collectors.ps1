$results = @()
$city=Read-Host "Please enter city you wish (RU)/Пожалуйста введите город(RU)"
$department=Read-Host "Please enter department (RU)/Пожалуйста введите отдел(RU)"
$users = Get-ADUser -SearchBase "OU=$department,OU=Пользователи,OU=$city,OU=Cities,DC=2gis,DC=local"  -Properties memberof -Filter * 
foreach ($user in $users) {
    $groups = $user.memberof -join ';'
    $results += New-Object psObject -Property @{'User'=$user.name;'Groups'= $groups}
    }
$results | Where-Object { $_.groups -notmatch 'crm.collectorgroup' } | Select-Object user
