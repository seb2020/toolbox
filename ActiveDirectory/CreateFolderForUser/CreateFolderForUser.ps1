# ..######.
# .##....##
# .##......
# ..######.
# .......##
# .##....##
# ..######.

<#
.SYNOPSIS
    Script to bulk create folder for users (user has full control of the folder)
.DESCRIPTION
     CSV file format : "folderName","samAccountName"
.NOTES
    File Name      : CreateFolderForUser.ps1
.EXAMPLE
    .\CreateFolderForUser.ps1 -CSVFilePath .\exemple.csv -FolderRoot C:\temp\
#>


param
(
    [Parameter(Mandatory=$true)]
    [string] 
    $CSVFilePath,
    
    [Parameter(Mandatory=$false)]
    $FolderRoot
)    


# Check user input
if(-not(Test-Path -Path $CSVFilePath))
{
    Write-Error ("The file '" + $CSVFilePath + "' was not found")
    exit
}

if(($FolderRoot) -and (-not(Test-Path -Path $FolderRoot)))
{
    Write-Error ("The folder root '" + $FolderRoot + "' does not exist")
    exit
}


# Get and check CSV file format
try
{
    $header = "folderName","samAccountName"
    $headerStr = "folderName,samAccountName"
    
    $folders = Import-Csv -Path $CSVFilePath -Header $header
    $colNum = ($folders | get-member -type NoteProperty).Count
    
    if(-not($colNum -eq 2))
    {
        Write-Error ("Invalid arguments number in '" + $CSVFilePath + "'. Arguments must be : " + $headerStr)
        exit
    }
    
    # Check data validity
    $line = 1
    $checkErrors = 0
    
    foreach($folder in $folders)
    {
        if(-not ($folder.folderName) -or (-not($folder.samAccountName)))
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
    # Create each user
    foreach($folder in $folders)
    {
        # Create the folder and configure ACL
        $dir = Join-Path $FolderRoot $folder.folderName
        New-Item -Path $dir -ItemType Directory | Out-Null
        
        $acls = Get-Acl -Path $dir
        
        # User = Full Control
        $acl = New-Object System.Security.AccessControl.FileSystemAccessRule($folder.samAccountName, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
        $acls.AddAccessRule($acl)
            
        Set-Acl -AclObject $acls -Path $dir    
    }
}
catch
{
    Write-Error ($_.Exception.GetType().ToString() + " : " + $_)     
    Write-Error "Manual cleanup in filesystem may be necessary !"
    exit
}

Write-Output "Folders successfully created"