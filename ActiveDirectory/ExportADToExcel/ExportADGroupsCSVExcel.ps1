<#
.SYNOPSIS
    Export all ActiveDirectory group from a specified server with a specified account
.DESCRIPTION
    Export all ActiveDirectory group from a specified server with a specified account to a CSV file. Then the file is converted to an Excel XLSX document.
.NOTES
    File Name      :  ExportADGroupsCSVExcel.ps1
.EXAMPLE
    .\ExportADGroupsCSVExcel.ps1
#>

param
(
    [Parameter(Mandatory=$true)]
    [string] 
    $FilterGroupName
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
    if ($FilterGroupName -ne "*")
    {
        $global:CSVFile = [Environment]::GetFolderPath("Desktop")+"\"+$FilterGroupName.Substring(0,$FilterGroupName.Length-1)+"_"+$global:DateTime+".csv" 
    } else {
        $global:CSVFile = [Environment]::GetFolderPath("Desktop")+"\"+"_full_"+$global:DateTime+".csv"
    }

    #// Create emy array for CSV data 
    $CSVOutput = @() 
 
    #// Get all AD groups in the domain 
    $ADGroups = Get-ADGroup -Filter {name -like $FilterGroupName}
 
    #// Set progress bar variables 
    $i=0 
    $tot = $ADGroups.count 
 
    foreach ($ADGroup in $ADGroups) { 
        #// Set up progress bar 
        $i++ 
        $status = "{0:N0}" -f ($i / $tot * 100) 
        Write-Progress -Activity "Exporting AD Groups" -status "Processing Group $i of $tot : $status% Completed" -PercentComplete ($i / $tot * 100) 
 
        #// Ensure Members variable is empty 
        $Members = "" 
 
        #// Get group members which are also groups and add to string 
        $MembersArr = Get-ADGroup -filter {Name -eq $ADGroup.Name} | Get-ADGroupMember | select Name 
        if ($MembersArr) { 
            foreach ($Member in $MembersArr) { 
                $Members = $Members + "," + $Member.Name 
            } 
            $Members = $Members.Substring(1,($Members.Length) -1) 
        } 
 
        #// Set up hash table and add values 
        $HashTab = $NULL 
        $HashTab = [ordered]@{ 
            "Name" = $ADGroup.Name 
            "Category" = $ADGroup.GroupCategory 
            "Scope" = $ADGroup.GroupScope 
            "Members" = $Members 
        } 
 
        #// Add hash table to CSV data array 
        $CSVOutput += New-Object PSObject -Property $HashTab 
    } 
 
    #// Export to CSV files 
    $CSVOutput | Sort-Object Name | Export-Csv $global:CSVFile -NoTypeInformation -Delimiter ";"
}

function exportExcel
{
    ### Set input and output path
    $inputCSV = $global:CSVFile
        #// Set CSV file name
    if ($FilterGroupName -ne "*")
    {
        $outputXLSX = [Environment]::GetFolderPath("Desktop")+"\"+$FilterGroupName.Substring(0,$FilterGroupName.Length-1)+"_"+$global:DateTime+"_excel.xlsx" 
    } else {
        $outputXLSX = [Environment]::GetFolderPath("Desktop")+"\"+"_full_"+$global:DateTime+"_excel.xlsx"
    }


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
    exportExcel
     	
    $PSDefaultParameterValues.Clear()
    $global:credentials = ""
} 
else 
{
    write-host "Missing powershell module. You need to install the AD module"
}

#// End of script