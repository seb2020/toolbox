<#
.SYNOPSIS
    Export all folder rights from a specified server with a specified account
.DESCRIPTION
    Export all folder rights from a specified server with a specified account to a CSV file. Then the file is converted to an Excel XLSX document.
.NOTES
    File Name      :  ExportAllFolderRights.ps1
.EXAMPLE
    .\ExportAllFolderRights.ps1
#>

param
(
    [Parameter(Mandatory=$true)]
    [string] 
    $share
)   

$global:credentials = [System.Management.Automation.PSCredential]::Empty
$global:server = ""
$global:CSVFile = ""
$global:DateTime = Get-Date -f "yyyy-MM"

function checkRequirements
{
    if (Get-Module -ListAvailable -Name "ActiveDirectory") {
        return 0
    } else {
        return 1
    }
}
function getCredentials
{
    $global:credentials = Get-Credential
}

function getServer
{
    Add-Type -AssemblyName Microsoft.VisualBasic
    $global:server = [Microsoft.VisualBasic.Interaction]::InputBox('Enter a server name', 'ActiveDirectory server name', "")
}

function exportCSV
{
 
    #// Set CSV file name 
    $global:CSVFile = [Environment]::GetFolderPath("Desktop")+"\"+$global:DateTime+"_right.csv" 
 
    $FolderPath = dir -Directory -Path $share -Force
    $Report = @()
    Foreach ($Folder in $FolderPath) {
        $Acl = Get-Acl -Path $Folder.FullName
        foreach ($Access in $acl.Access)
            {
                $Properties = [ordered]@{'FolderName'=$Folder.FullName;'AD
                    Group or
                    User'=$Access.IdentityReference;'Permissions'=$Access.FileSystemRights;'Inherited'=$Access.IsInherited}
                $Report += New-Object -TypeName PSObject -Property $Properties
            }
    }
 
    #// Export to CSV files 
    $CSVOutput | Export-Csv $global:CSVFile -NoTypeInformation -Delimiter ";"
}

function exportExcel
{
    ### Set input and output path
    $inputCSV = $global:CSVFile
    $outputXLSX = [Environment]::GetFolderPath("Desktop")+"\"+$global:DateTime+"_excel.xlsx" 

    ### Create a new Excel Workbook with one empty sheet
    $excel = New-Object -ComObject excel.application 
    $workbook = $excel.Workbooks.Add(1)
    $worksheet = $workbook.worksheets.Item(1)

    ### Build the QueryTables.Add command
    ### QueryTables does the same as when clicking "Data » From Text" in Excel
    $TxtConnector = ("TEXT;" + $inputCSV)
    $Connector = $worksheet.QueryTables.add($TxtConnector,$worksheet.Range("A1"))
    $query = $worksheet.QueryTables.item($Connector.name)

    ### Set the delimiter (, or ;) according to your regional settings
    $query.TextFileOtherDelimiter = $Excel.Application.International(5)

    ### Set the format to delimited and text for every column
    ### A trick to create an array of 2s is used with the preceding comma
    $query.TextFileParseType  = 1
    $query.TextFileColumnDataTypes = ,2 * $worksheet.Cells.Columns.Count
    $query.AdjustColumnWidth = 1

    ### Execute & delete the import query
    $query.Refresh()
    $query.Delete()

    ### Save & close the Workbook as XLSX. Change the output extension for Excel 2003
    $Workbook.SaveAs($outputXLSX,51)
    $excel.Quit()
}

$requirementStatus = checkRequirements
if ($requirementStatus -eq 0)
{
    getCredentials
    getServer
    $PSDefaultParameterValues = @{
        "*-AD*:Credential"=$global:credentials;
        "*-AD*:Server"=$global:server
    }
    Write-Host "Connecting to "$global:server " with credentials " $global:credentials
    exportCSV
    #exportExcel
     	
    $PSDefaultParameterValues.Clear()
    $global:credentials = ""
} 
else 
{
    write-host "Missing powershell module. You need to install the AD module"
}

#// End of script