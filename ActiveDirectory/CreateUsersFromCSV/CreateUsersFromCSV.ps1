# ..######.
# .##....##
# .##......
# ..######.
# .......##
# .##....##
# ..######.

<#
.SYNOPSIS
    Script to bulk create users in AD from a CSV file
.DESCRIPTION
    CSV file format : "givenName,sn,displayName,sAMAccountName,userPrincipalName,description,mail,enabled,mustChangepassword"
.NOTES
    File Name      : BulkCrateGroups.ps1
.EXAMPLE
    .\CreateUsersFromCSV.ps1 -CSVFilePath .\exemple.csv -OrganizationalUnitDN "DC=Staff,DC=domain,DC=local" -HomeFolderRoot "D:\UsersProfiles\"
#>

param
(
    [Parameter(Mandatory=$true)]
    [string] 
    $CSVFilePath,
    
    [Parameter(Mandatory=$true)]
    [string] 
    $OrganizationalUnitDN,
    
    [Parameter(Mandatory=$false)]
    $HomeFolderRoot
)    

if(-not(Get-Module | Where-Object {$_.Name -like "ActiveDirectory"})){Import-Module ActiveDirectory -Verbose:$false}


# Ask the user to provide all required information
$password = Read-Host “Please enter users default password” -AsSecureString


# Check user input
if(-not(Test-Path -Path $CSVFilePath))
{
    Write-Error ("The file '" + $CSVFilePath + "' was not found")
    exit
}

if(($HomeFolderRoot) -and (-not(Test-Path -Path $HomeFolderRoot)))
{
    Write-Error ("The homefolder root '" + $HomeFolderRoot + "' does not exist")
    exit
}

try
{
    $ou = Get-ADOrganizationalUnit -Identity $OrganizationalUnitDN
}

catch
{
    Write-Error ("The OU '" + $basOu + "' does not exist")
    exit
}


# Get and check CSV file format
try
{
    $header = "givenName","sn","displayName","sAMAccountName","userPrincipalName","description","mail","enabled","mustChangepassword"
    $headerStr = "givenName,sn,displayName,sAMAccountName,userPrincipalName,description,mail,enabled,mustChangepassword"
    
    $users = Import-Csv -Path $CSVFilePath -Header $header
    $colNum = ($users | get-member -type NoteProperty).Count
    
    if(-not($colNum -eq 9))
    {
        Write-Error ("Invalid arguments number in '" + $CSVFilePath + "'. Arguments must be : " + $headerStr)
        exit
    }
    
    # Check data validity
    $line = 1
    $checkErrors = 0
    
    foreach($user in $users)
    {
        if(-not ($user.givenName) -or (-not($user.sn)) -or (-not($user.displayName)) -or (-not($user.sAMAccountName)) `
            -or (-not($user.userPrincipalName)) -or (-not($user.enabled)) -or (-not($user.mustChangepassword)))
        {
            Write-Warning ("An invalid entry was found in " + $CSVFilePath + " on line " + $line + ". Please remove any blank line and complete missing user attributes.")
            Write-Warning ("Valid CSV entries format : " + $headerStr)
            $checkErrors++
        }
        
        $line++
    }

    if($checkErrors -gt 0)
    {
        Write-Error "Errors were found in CSV file. Please correct them and try again."
        exit
    }
}
catch
{
    Write-Error "An error occured while validating users parameters"
    Write-Error ($_.Exception.GetType().ToString() + " : " + $_)     
    exit
}


try
{
    $dc = (Get-ADDomainController -Discover).HostName[0].ToString()

    # Create each user
    foreach($user in $users)
    {
        $enabled = [System.Convert]::ToBoolean($user.enabled)
        $changePwd = [System.Convert]::ToBoolean($user.mustChangepassword)
        $sAMAcc = $user.sAMAccountName.Trim()
        
        # Create the user
        New-ADUser -GivenName $user.givenName.Trim() -Surname $user.sn.Trim() -DisplayName $user.displayName.Trim() -UserPrincipalName $user.userPrincipalName.Trim() -Path $OrganizationalUnitDN  `
            -Name $user.displayName.Trim() -EmailAddress $user.mail.Trim() -SamAccountName $sAMAcc -AccountPassword $password -Description $user.description.Trim() -Server $dc
     
        $newUser = Get-ADUser -Filter {sAMAccountName -eq $sAMAcc} -Server $dc
        
        
        # Set user values
        if($enabled)
        {
            Enable-ADAccount -Identity $newUser -Server $dc
        }
        
        if($changePwd)
        {    
            Set-ADUser -Identity $newUser -ChangePasswordAtLogon $true -Server $dc
        }
        
        
        # Create the user homefolder and configure ACL
        if($HomeFolderRoot)
        {
            $dir = Join-Path $HomeFolderRoot $sAMAcc
            New-Item -Path $dir -ItemType Directory | Out-Null
            
            $acls = Get-Acl -Path $dir
            
            # User = Full Control
            $acl = New-Object System.Security.AccessControl.FileSystemAccessRule($sAMAcc, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
            $acls.AddAccessRule($acl)
                
            Set-Acl -AclObject $acls -Path $dir
        }
    }
}
catch
{
    Write-Error ($_.Exception.GetType().ToString() + " : " + $_)     
    Write-Error "Manual cleanup in AD or filesystem may be necessary !"
    exit
}

Write-Output "Users successfully created"