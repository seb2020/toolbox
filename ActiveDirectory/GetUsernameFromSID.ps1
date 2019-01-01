# ..######.
# .##....##
# .##......
# ..######.
# .......##
# .##....##
# ..######.

<#
.SYNOPSIS
    Find the username with SID
.DESCRIPTION
    SID of the user
.NOTES
    File Name      : GetUsernameFromSID.ps1
#>

param
(
    [Parameter(Mandatory=$true)]
    [string] 
    $SID
)   

$SID = New-Object System.Security.Principal.SecurityIdentifier($SID) 
$User = $SID.Translate( [System.Security.Principal.NTAccount]) 
$User.Value