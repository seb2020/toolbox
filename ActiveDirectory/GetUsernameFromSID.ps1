# Script to get usname from SID

param
(
    [Parameter(Mandatory=$true)]
    [string] 
    $SID
)   

$SID = New-Object System.Security.Principal.SecurityIdentifier($SID) 
$User = $SID.Translate( [System.Security.Principal.NTAccount]) 
$User.Value