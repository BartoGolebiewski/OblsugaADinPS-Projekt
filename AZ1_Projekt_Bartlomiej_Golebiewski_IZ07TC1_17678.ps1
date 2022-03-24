#Bartłomiej Gołębiewski IZ07TC1 17678 AZ1_Projekt
##################################################
#Zbiór funkcji potrzebnych do dzialania
##################################################

#funkcja tworzaca konto uzytkownika AD
function Dodawanie-Usera
{
    Write-Host "Tworzenie nowego uzytkownika"
    $imie = Read-Host "Podaj Imie"
    $nazwisko = Read-Host "Podaj Nazwisko"
    $dzial = Read-Host "Podaj Dzial"
    #utworzenie loginu na podstawie imienia i nazwiska
    $login = $imie+"."+$nazwisko
    #znalezienie wolnego loginu
    $zapamietaj = $login
    $i = 1
    While(Get-ADUser -Filter "sAMAccountName -eq '$($login)'")
    {
        $login = $zapamietaj
        $login = $login+$i
        $i++
    }
    #wyciagniecie informacji o domenie
    $infodomena = Get-ADDomain
    $domena = $infodomena.Forest
    #utworzenie maila na podstawie loginu i domeny
    $email = $login+"@"+$domena
    #utworzenie nazwy na podstawie imienia i nazwiska
    $nazwa = $imie+" "+$nazwisko
    $i=1
    $zapamietaj=$nazwa
    While(Get-ADUser -Filter "Name -eq '$($nazwa)'")
    {
        $nazwa = $zapamietaj
        $nazwa = $nazwa+$i
        $i++
    }
    #generowanie hasla
    $haslo = ""
    for($i = 1; $i -le 10; $i++)
    {
        $haslo += [char](Get-Random -Minimum 48 -Maximum 122)
    }
    #konwertowanie hasla
    $hasloAD = ConvertTo-SecureString $haslo -AsPlainText -Force

    #tworzenie katalogu dla plikow z haslami uzytkownikow
    $sciezka = '.\Konta-haslo'
    if(!(Test-Path -Path $sciezka))
    {
        New-Item -ItemType "directory" -Path $sciezka
    }
    #tworzenie pliku z haslem uzytkownika
    $plik = "17678_$nazwa.csv"
    New-Item -ItemType "file" -Name $plik -Path $sciezka
    "$login,$haslo"|Out-File -FilePath "$sciezka\$plik"

    #wskazanie jednostki organizacyjnej na konta
    $dn = $infodomena.DistinguishedName
    $ou = "OU=Projekt,"+$dn
    #sprawdzenie czy ou istnieje
    if (!(Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$ou'")) 
    {
        New-ADOrganizationalUnit -Name "Projekt" -Path $dn 
    }
    #tworzenie uzytkownika AD
    New-ADUser -DisplayName: $nazwa -GivenName: $imie  -Surname:$nazwisko -Name: $nazwa  -Department: $dzial -Path: $ou -SamAccountName: $login -UserPrincipalName: $login -EmailAddress $email -Enabled $true -Accountpassword $hasloAD
    #pobranie daty i informacji kto
    $kto = whoami
    $kiedy = Get-Date
    #tworzenie katalogu dla plikow z logami
    $sciezka = '.\Logi'
    if(!(Test-Path -Path $sciezka))
    {
        New-Item -ItemType "directory" -Path $sciezka
    }
    #tworzenie pliku z logami dotyczace tworzenia konta uzytkownika
    $sciezka = '.\Logi\17678-create_user.csv'
    {
        New-Item -ItemType "file" -Path '.\Logi\' -Name '17678-create_user.csv'
        "kto,kiedy,konto" | Out-File -FilePath $sciezka -Encoding utf8
    }
    "$kto,$kiedy,$login" | Out-File -FilePath $sciezka -Encoding utf8 -Append

}

#funkcja tworzaca wiele kont uzytkowika AD na podstawie uzytkownicy.csv
function DodawanieWielu-Userow
{
    Write-Host "Tworzenie wielu uzytkownikow"
    #tworzenie pustego pliku csv do uzupelnienia
    $sciezka = ".\uzytkownicy.csv"
    if(!(Test-Path -Path $sciezka))
    {
        New-Item -ItemType "file" -Name "uzytkownicy.csv" -Path ".\" 
        "imie,nazwisko,dzial" | Out-File -FilePath $sciezka -Append -Encoding utf8
        Write-Host "Utworzono plik uzytkownicy.csv w lokalizacji C:\Projekt."
    }
    else
    {
        #wczytanie pliku csv
       $csv = Import-Csv -Path ".\uzytkownicy.csv" -Encoding UTF8 -Delimiter ","
       #petla tworzaca kolejnych uzytkownikow
       foreach($konto in $csv)
       {
            #pobranie danych z pliku csv
            $imie = $konto.imie
            $nazwisko =$konto.nazwisko
            $dzial = $konto.dzial

            $login = $imie+"."+$nazwisko
            $zapamietaj = $login
            $i = 1
            While(Get-ADUser -Filter "sAMAccountName -eq '$($login)'")
            {
                $login = $zapamietaj
                $login = $login+$i
                $i++
            }
            #wyciagniecie informacji o domenie
            $infodomena = Get-ADDomain
            $domena = $infodomena.Forest
            #utworzenie maila na podstawie loginu i domeny
            $email = $login+"@"+$domena
            #utworzenie nazwy na podstawie imienia i nazwiska
            $nazwa = $imie+" "+$nazwisko
            $i=1
            $zapamietaj=$nazwa
            While(Get-ADUser -Filter "Name -eq '$($nazwa)'")
            {
                $nazwa = $zapamietaj
                $nazwa = $nazwa+$i
                $i++
            }
            #generowanie hasla
            $haslo = ""
            for($i = 1; $i -le 10; $i++)
            {
                $haslo += [char](Get-Random -Minimum 48 -Maximum 122)
            }
            #konwertowanie hasla
            $hasloAD = ConvertTo-SecureString $haslo -AsPlainText -Force

            #tworzenie katalogu dla plikow z haslami uzytkownikow
            $sciezka = '.\Konta-haslo'
            if(!(Test-Path -Path $sciezka))
            {
                New-Item -ItemType "directory" -Path $sciezka
            }
            #tworzenie pliku z haslem uzytkownika
            $plik = "17678_$nazwa.csv"
            New-Item -ItemType "file" -Name $plik -Path $sciezka
            "$login,$haslo"|Out-File -FilePath "$sciezka\$plik"

            #wskazanie jednostki organizacyjnej na konta
            $dn = $infodomena.DistinguishedName
            $ou = "OU=Projekt,"+$dn
            #sprawdzenie czy ou istnieje
            if (!(Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$ou'")) 
            {
                New-ADOrganizationalUnit -Name "Projekt" -Path $dn 
            }
            #tworzenie uzytkownika AD
            New-ADUser -DisplayName: $nazwa -GivenName: $imie  -Surname:$nazwisko -Name: $nazwa  -Department: $dzial -Path: $ou -SamAccountName: $login -UserPrincipalName: $login -EmailAddress $email -Enabled $true -Accountpassword $hasloAD
            #pobranie daty i informacji kto
            $kto = whoami
            $kiedy = Get-Date
            #tworzenie katalogu dla plikow z logami
            $sciezka = '.\Logi'
            if(!(Test-Path -Path $sciezka))
            {
                New-Item -ItemType "directory" -Path $sciezka
            }
            #tworzenie pliku z logami dotyczace tworzenia konta uzytkownika
            $sciezka = '.\Logi\17678-create_user.csv'
            if(!(Test-Path -Path $sciezka))
            {
                New-Item -ItemType "file" -Path '.\Logi\' -Name '17678-create_user.csv'
                "kto,kiedy,konto" | Out-File -FilePath $sciezka -Encoding utf8
            }
            "$kto,$kiedy,$login" | Out-File -FilePath $sciezka -Encoding utf8 -Append
       } 
    }
}

#funkcja blokujaca konta

function Blokada-Usera
{
    #pobranie loginu od uzytkownika
    Write-Host "Blokowanie konta"
    $login = Read-Host "Podaj login"
    #wylaczenie konta
    Set-ADUser -Identity $login -Enabled $false
    #pobranie daty i informacji kto
    $data = Get-Date -Format("dd.MM.yyyy")
    $kto = whoami
    #tworzenie katalogu dla plikow z logami
            $sciezka = '.\Logi'
            if(!(Test-Path -Path $sciezka))
            {
                New-Item -ItemType "directory" -Path $sciezka
            }
            #tworzenie pliku z logami dotyczace tworzenia konta uzytkownika
            $sciezka = '.\Logi\17678-zablokowane_konta-$data.csv'
            if(!(Test-Path -Path $sciezka))
            {
                New-Item -ItemType "file" -Path '.\Logi\' -Name '17678-zablokowane_konta-$data.csv'
                "kto,kiedy,konto" | Out-File -FilePath $sciezka -Encoding utf8
            }
            "$kto,$kiedy,$login" | Out-File -FilePath $sciezka -Encoding utf8 -Append

}

#funkcja zmieniajaca haslo
function Zmiana-Hasla
{
    Write-Host "Zmienianie hasla"
    #pobranie loginu i hasla od uzytkownika
    $login = Read-Host "Podaj login"
    $haslo = Read-Host "Podaj haslo"
    #konwertowanie hasla
    $hasloAD = ConvertTo-SecureString $haslo -AsPlainText -Force
    #zmiana hasla uzytkownika
    Set-ADAccountPassword -Identity $login -NewPassword $hasloAD -Reset:$true 
    #pobranie daty i informacji kto
    $kiedy = Get-Date -Format("dd-MM-yyyy")
    $kto = whoami
    #tworzenie katalogu dla plikow z logami
            $sciezka = '.\Logi'
            if(!(Test-Path -Path $sciezka))
            {
                New-Item -ItemType "directory" -Path $sciezka
            }
            #tworzenie pliku z logami dotyczace tworzenia konta uzytkownika
            $sciezka = ".\Logi\17678-zmiana_hasla-$kiedy.csv"
            if(!(Test-Path -Path $sciezka))
            {
                New-Item -ItemType "file" -Path ".\Logi\" -Name "17678-zmiana_hasla-$kiedy.csv"
                "kto,kiedy,konto" | Out-File -FilePath $sciezka -Encoding utf8
            }
            "$kto,$kiedy,$login" | Out-File -FilePath $sciezka -Encoding utf8 -Append
}

#funkcja tworzaca nowa grupe
function Nowa-Grupa
{
    #pobranie loginu i hasla od uzytkownika
    Write-Host "Tworzenie nowej grupy"
    $grupa = Read-Host "Podaj nazwe grupy"
    if(Get-ADGroup -Filter "sAMAccountName -eq '$($grupa)'")
    {
        Write-Host "Grupa juz istnieje"
    }
    else
    {
        $infodomena = Get-ADDomain
        $dn = $infodomena.DistinguishedName
        
        $ou = "OU=Projekt,"+$dn
        #sprawdzenie czy ou istnieje
        if (!(Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$ou'")) 
        {
            New-ADOrganizationalUnit -Name "Projekt" -Path $dn 
        }
        New-ADGroup -Name $grupa -DisplayName $grupa -SamAccountName $grupa -Path $ou -GroupCategory Security -GroupScope Global
        #pobranie daty i informacji kto
        $kiedy = Get-Date 
        $kto = whoami
        #tworzenie katalogu dla plikow z logami
        $sciezka = '.\Logi'
            if(!(Test-Path -Path $sciezka))
            {
                New-Item -ItemType "directory" -Path $sciezka
            }
            #tworzenie pliku z logami dotyczace tworzenia konta uzytkownika
            $sciezka = '.\Logi\17678-create_group.csv'
            if(!(Test-Path -Path $sciezka))
            {
                New-Item -ItemType "file" -Path '.\Logi\' -Name '17678-create_group.csv'
                "kto,kiedy,grupa" | Out-File -FilePath $sciezka -Encoding utf8
            }
            "$kto,$kiedy,$grupa" | Out-File -FilePath $sciezka -Encoding utf8 -Append

    }
}

#funkcja dodajaca konto do grupy
function DodajDo-Grupy
{
    #pobranie loginu i hasla od uzytkownika
    Write-Host "Dodawanie do grupy"
    $grupa = Read-Host "Podaj nazwe grupy"
    $login = Read-Host "Podaj login uzytkownika"
    #dodanie do grupy
    Add-ADGroupMember -Identity $grupa -Members $login
    #pobranie daty i informacji kto
    $kiedy = Get-Date 
    $kto = whoami
    #tworzenie katalogu dla plikow z logami
        $sciezka = '.\Logi'
            if(!(Test-Path -Path $sciezka))
            {
                New-Item -ItemType "directory" -Path $sciezka
            }
            #tworzenie pliku z logami dotyczace tworzenia konta uzytkownika
            $sciezka = '.\Logi\17678-zmiana_czlonkostwa_grup.txt'
            if(!(Test-Path -Path $sciezka))
            {
                New-Item -ItemType "file" -Path '.\Logi\' -Name '17678-zmiana_czlonkostwa_grup.txt'
                "kto,kiedy,grupa,login" | Out-File -FilePath $sciezka -Encoding utf8
            }
            "$kto,$kiedy,$grupa,$login" | Out-File -FilePath $sciezka -Encoding utf8 -Append


}

#funkcja tworzaca liste grup
function Lista-Grup
{
    Write-Host "Tworzenie listy grup"
    #pobranie wszystkich grup z AD
    $lista = Get-ADGroup -Filter *
    $lista = $lista.SamAccountName

    foreach($grupa in $lista)
    {
        #znalezienie czlonków grupy z listy
        $czlonkowie = Get-ADGroupMember -Identity $grupa
        $czlonkowie = $czlonkowie.SamAccountName
        #tworzenie katalogu dla plikow z czlonkami grup
        $sciezka = '.\Grupy'
            if(!(Test-Path -Path $sciezka))
            {
                New-Item -ItemType "directory" -Path $sciezka
            }
            #tworzenie pliku z logami dotyczace tworzenia konta uzytkownika
            $sciezka = ".\Grupy\17678-$grupa.txt"
            if(!(Test-Path -Path $sciezka))
            {
                New-Item -ItemType "file" -Path '.\Logi\' -Name "17678-$grupa.txt"
            }
            "$czlonkowie" | Out-File -FilePath $sciezka -Encoding utf8
    }
}

#funkcja tworzaca liste zablokowanych kont
function ListaZablokowanych-Kont
{
    Write-Host "Tworzenie listy zablokowanych kont"
    #pobranie wylaczonych kont uzytkownikow
    $konta = Get-ADUser -Properties whenChanged -Filter {Enabled -eq $False} | select Name, DistinguishedName, SID, whenChanged
    #tworzenie katalogu dla plikow z zablokowanymi kontami
    $sciezka = '.\Konta-zablokowane'
            if(!(Test-Path -Path $sciezka))
            {
                New-Item -ItemType "directory" -Path $sciezka
            }
            #tworzenie pliku z logami dotyczace tworzenia konta uzytkownika
            $sciezka = '.\Konta-zablokowane\17678-zablokowane_konta.csv'
            $konta | Export-Csv -Path $sciezka -NoTypeInformation -Encoding UTF8
}

#funkcja tworzaca liste kont
function Lista-Kont
{
    Write-Host "Tworzenie listy kont"
    #pobranie wszystkich kont uzytkownikow
    $konta = Get-ADUser -Properties * -Filter * | select GivenName, SurName, UserPrincipalName, SamAccountName, DistinguishedName, whenCreated, whenChanged, LastLogon, PasswordLastSet
    #tworzenie katalogu dla plikow z kontami
    $sciezka = '.\Konta'
            if(!(Test-Path -Path $sciezka))
            {
                New-Item -ItemType "directory" -Path $sciezka
            }
            #tworzenie pliku z logami dotyczace tworzenia konta uzytkownika
            $sciezka = '.\Konta\17678-uzytkownicy.csv'
            $konta | Export-Csv -Path $sciezka -NoTypeInformation -Encoding UTF8
}

#funkcja tworzaca liste jednostek org.
function Lista-JOrg
{
    Write-Host "Tworzenie listy jednostek org."
    #pobranie wszystkich jednostek org
    $jednostki = Get-ADOrganizationalUnit -Filter * | select Name, DistinguishedName | Sort-Object DistinguishedName
    #tworzenie katalogu dla plikow z j. org.
    $sciezka = '.\Jednostki'
            if(!(Test-Path -Path $sciezka))
            {
                New-Item -ItemType "directory" -Path $sciezka
            }
            #tworzenie pliku z logami dotyczace tworzenia konta uzytkownika
            $sciezka = '.\Jednostki\17678-jednostki.csv'
            $jednostki | Export-Csv -Path $sciezka -NoTypeInformation -Encoding UTF8
}

#funkcja wypisujaca informacje o domenie
function Info-Domena
{
   Write-Host "Wypisywanie informacji o domenie"
   #pobranie informacji o domenie
   $domena = Get-ADDomain | select Name, NetBIOSName, DomainMode, DomainSID, ComputersContainer, UsersContainer
   #tworzenie katalogu dla domeny
    $sciezka = '.\Domena'
            if(!(Test-Path -Path $sciezka))
            {
                New-Item -ItemType "directory" -Path $sciezka
            }
            #tworzenie pliku z logami dotyczace tworzenia konta uzytkownika
            $sciezka = '.\Domena\17678-domain_info.csv'
            $domena | Export-Csv -Path $sciezka -NoTypeInformation -Encoding UTF8 
 
}

#funkcja tworzaca liste komputerow
function Lista-Komputerow
{
    Write-Host "Tworzenie listy komputerow."
    #pobranie wszystkich komputerow
    $komputery = Get-ADComputer -Filter * -Properties * | Select-Object name, operatingSystem, SID, DistinguishedName, Enabled, PasswordLastSet, Created
    #stworzenie unikatowej listy systemow
    $systemy =  $komputery.operatingSystem | select -Unique
    #tworzenie katalogu dla komputerow
    $sciezka = '.\Komputery'
            if(!(Test-Path -Path $sciezka))
            {
                New-Item -ItemType "directory" -Path $sciezka
            }
    
    ForEach($system in $systemy)
    {
        
        $komputer = $komputery | Where-Object {$_.operatingSystem -eq $system}
        #wyciagniecie informacji o domenie
        $infodomena = Get-ADDomain
        $domena = $infodomena.Forest
        $sciezka = ".\Komputery\17678-$domena-$system.csv"
        $komputer | Export-Csv -Path $sciezka -Encoding utf8 -NoTypeInformation
    }
     
}
##################################################
#Menu
##################################################
cls


Write-Host "Wybierz opcje z menu: 
1-konta użytkownika
2-grupy
3-raporty"
$opcje = Read-Host "Podaj numer"
switch($opcje)
{
    1{
    Write-Host "Wybierz podopcje:
    1-tworzenie konta
    2-tworzenie wielu kont
    3-blokowanie konta
    4-zmiana hasla"
    $podopcje = Read-Host "Podaj numer"
    switch($podopcje)
    {
        1{
            Dodawanie-Usera
        }
        2{
            DodawanieWielu-Userow
        }
        3{
            Blokada-Usera
        }
        4{
            Zmiana-Hasla
        }
    }
    }
    2{
    Write-Host "Wybierz podopcje:
    1-tworzenie grupy
    2-dodawanie do grupy"
    $podopcje = Read-Host "Podaj numer"
    switch($podopcje)
    {
        1{
            Nowa-Grupa
        }
        2{
            DodajDo-Grupy
        }
    }
    }
    3{
    Write-Host "Wybierz podopcje:
    1-lista grup
    2-lista zablokowanych kont
    3-lista informacji o użytkownikach
    4-lista informacji o komputerach
    5-lista jednostek organizacyjnych
    6-lista informacji o domenie"
    $podopcje = Read-Host "Podaj numer"
    switch($podopcje)
    {
        1{
            Lista-Grup
        }
        2{
            ListaZablokowanych-Kont
        }
        3{
            Lista-Kont
        }
        4{
            Lista-Komputerow
        }
        5{
            Lista-JOrg
        }
        6{
            Info-Domena
        }
    }
    }


}