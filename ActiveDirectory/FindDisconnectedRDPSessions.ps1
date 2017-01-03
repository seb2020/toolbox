# ..######.
# .##....##
# .##......
# ..######.
# .......##
# .##....##
# ..######.

<#
.SYNOPSIS
    Find disconnected session on local computer
.DESCRIPTION
    Find disconnected session on local computer
.NOTES
    File Name      : FindDisconnectedRDPSessions.ps1
    
#>

$ComputerName = $env:COMPUTERNAME
$queryResults = (qwinsta /server:$ComputerName| foreach { (($_.trim() -replace "\s+",","))} | ConvertFrom-Csv)  
ForEach ($queryResult in $queryResults) { 
    $Hash = @{
        ComputerName = $ComputerName
        UserName     = $($queryResult.USERNAME)
        SessionId    = $($queryResult.SESSIONNAME -replace 'rdp-tcp#','')
    }
    # Check the session state
    switch ($queryResult.username) {
        # If UserName is a number, it's an unused session
        {$_ -match "[0-9]"} {
            $Hash.Add("SessionState","InActive")
            break
        }
        {$_ -match "[a-zA-Z]"} {
            $Hash.Add("SessionState","Active")
            break
        }
        default {
            $Hash.Add("SessionState","Unknown")
        }
    }
    New-Object -TypeName PSObject -Property $Hash
}