# ..######.
# .##....##
# .##......
# ..######.
# .......##
# .##....##
# ..######.

<#
.SYNOPSIS
    This script create groups in bulk mode based on a CSV file
.DESCRIPTION
    Input file must be in UTF-8 encoding
    Input file must not have any header
    Values must be separated by a semi colon (;)
    Valid columns are : GroupName;GroupType(Security=1,Distribution=0);GroupScope(DomainLocal=0,Global=1,Universal=2);GroupContainerDN;GroupDescription;GroupMembers(multiple members separated by a # character)

.NOTES
    File Name      : BulkCrateGroups.ps1
.EXAMPLE
    .\BulkCrateGroups.ps1 -InputFilePath .\exemple.csv
#>

param
(
    [Parameter(Mandatory=$true)]
    [string] 
    $InputFilePath, 
    
    [Parameter(Mandatory=$false)]
    [switch] 
    $WhatIf = $false
)


# Function to validate and get data from input file
function ValidateAndGetInputData
{
    param
    (
        [Parameter(Mandatory=$true)]
        [string] 
        $InputFilePath
    )
    
    try
    {
        $header = "GroupName","GroupType","GroupScope","GroupContainerDN","GroupDescription","GroupMembers"
        $headerStr = "GroupName;GroupType;GroupScope;GroupContainerDN;GroupDescription;GroupMembers"
        
        # Read data from file
        $groups = Import-Csv -Path $InputFilePath -Header $header -Delimiter ";" 
        $colNum = ($groups | get-member -type NoteProperty).Count
    
        if(-not($colNum -eq 6))
        {
            Write-Error ("Invalid arguments number in " + $InputFilePath + ". Arguments must be : " + $headerStr)
            return $null
        }
    
        # Check data validity
        $line = 1
        $checkErrors = 0
        
        foreach($group in $groups)
        {
            # Group description and members can be empty
            if(-not ($group.GroupName) -or (-not($group.GroupType)) -or (-not($group.GroupScope)) -or (-not($group.GroupContainerDN)))
            {
                Write-Warning ("An invalid entry was found in " + $InputFilePath + " at line " + $line + ". Please remove any blank line and complete missing attributes.")
                Write-Warning ("Valid entries format : " + $headerStr)
                $checkErrors++
            }
            
            if(($group.GroupType -lt 0) -or ($group.GroupType -gt 1))
            {
                Write-Warning ("An invalid entry was found in " + $InputFilePath + " at line " + $line + " for parameter 'GroupType'")
                Write-Warning ("Valid GroupType format : Security=1,Distribution=0")
                $checkErrors++
            }
            
            if(($group.GroupScope -lt 0) -or ($group.GroupScope -gt 2))
            {
                Write-Warning ("An invalid entry was found in " + $InputFilePath + " at line " + $line + " for parameter 'GroupScope'")
                Write-Warning ("Valid GroupScope format : DomainLocal=0,Global=1,Universal=2")
                $checkErrors++
            }
            
            $line++
        }
    
        if($checkErrors -gt 0)
        {
            Write-Error "Errors were found in CSV input file. Please correct them and try again."
            return $null
        }
        
        return $groups
    }
    catch 
    { 
        
        Write-Error ($_.Exception.GetType().ToString() + " : " + $_)
        Write-Error "Cannot get data from CSV input file. Please check input data."
        return $null
    }
}



if (-not (Get-Module | Where-Object {$_.Name -like "ActiveDirectory"})){Import-Module ActiveDirectory -Verbose:$false} 


# Validate input file format
$groups = ValidateAndGetInputData $InputFilePath

if(-not($groups))
{
    exit
}

try
{    
    foreach($group in $groups)
    {
        Write-Verbose ("Creating group : " + $group.GroupName + "...")
    
        # Create group
        New-ADGroup -Name $group.GroupName.Trim() -SamAccountName $group.GroupName.Trim() -DisplayName $group.GroupName.Trim() -GroupScope $group.GroupScope -GroupCategory $group.GroupType -Path $group.GroupContainerDN.Trim() -Description $group.GroupDescription.Trim() -WhatIf:$WhatIf
        
        # Add each member to group (cannot do WhatIf because group doesn't exist)
        if(-not($WhatIf))
        {
            $strMembers = $group.GroupMembers.split("#")
            
            if($strMembers)
            {
                foreach($str in $strMembers)
                {
                    Add-ADGroupMember -Identity $group.GroupName -Members $str
                }
            }
        }
        
        Write-Verbose ("Group " + $group.GroupName + " created.")
    }
}
catch 
{ 
    Write-Error ($_.Exception.GetType().ToString() + " : " + $_)
    Write-Warning ("Rollback of created groups has to be done manually !")
    exit
}