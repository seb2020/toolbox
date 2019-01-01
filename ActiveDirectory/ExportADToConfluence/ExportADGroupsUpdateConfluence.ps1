
<#
.SYNOPSIS
    Export group from ActiveDirectory to a CSV and update a Confluence page
.DESCRIPTION
    Export a group from a specified server with a specified account to a CSV file. Then the file is converted to HTML and updated to a Confluence page
.NOTES
    File Name      :  ExportADGroupsUpdateConfluence.ps1
    Config file available : 
    # test update api - Page id 000000 - Space ~user
.EXAMPLE
    .\ExportADGroupsUpdateConfluence.ps1
#>

########### -------- Global variables -------- ###########

$Global:Confluencecreds = [System.Management.Automation.PSCredential]::Empty

########### -------- Functions -------- ###########

function loadConfig
{
<#
.SYNOPSIS
    Load config file
#>
	try {
		$global:Config = Get-Content "ExportADGroupsUpdateConfluence_config_example.json" -Raw -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue | ConvertFrom-Json -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue
	} catch {
		Write-PoshError -Message "The Base configuration file is missing!" -Stop
	}

	# Check the configuration
	if (!($Config)) {
		Write-PoshError -Message "The Base configuration file is missing!" -Stop
	}
}
function checkRequirements
{
<#
.SYNOPSIS
    Check if all necessary module are avaible
#>
    if (Get-Module -ListAvailable -Name "ActiveDirectory") {
		Write-Host "Reqirements OK !" -ForegroundColor Green
        return 0
    } else {
        return 1
    }
}

function loadCredentialsWindows
{
<#
.SYNOPSIS
    Load Windows credentials and set default parameters for using command
#>
	$ADuser = $Global:Config.ADCredentials.Domain + "\" + $Global:Config.ADCredentials.Username
	$ADpasswordencrypted = $Global:Config.ADCredentials.PasswordSecureString | ConvertTo-SecureString

	$ADcreds = New-Object System.Management.Automation.PSCredential($ADuser,$ADpasswordencrypted)

    $PSDefaultParameterValues = @{
        "*-AD*:Credential"=$ADcreds
        "*-AD*:Server"=$Global:Config.ADInformations.Server
	}
}
function exportCSVandCreateHTML
{
<#
.SYNOPSIS
    Export all ActiveDirectory groups to a CSV file and then convert to an html table
#>
	$timestamp = Get-Date -f "d-MM-yyyy"
	$csvPath = $Global:Config.CSV.Path + $Global:Config.CSV.FileName + "_" + $timestamp + ".csv"

    #// Create emy array for CSV data 
    $CSVOutput = @() 
 
	#// Get all AD groups in the domain 
	$ADfilter = $Global:Config.ADInformations.Filter
    $ADGroups = Get-ADGroup -Filter {name -like $ADfilter}
 
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
	$CSVOutput | Sort-Object Name | Export-Csv $csvPath -NoTypeInformation -Delimiter ";"
	Write-Host "Export OK !" -ForegroundColor Green
	$resultHTML = $CSVOutput | ConvertTo-Html -Fragment | Out-String
	Write-Host "CSV to HTML convert OK !" -ForegroundColor Green
    return $resultHTML
}

function loadCredentialsConfluence
{
<#
.SYNOPSIS
    Load Confluence credentials into a variable
#>
	$Confluenceuser = $Global:Config.ConfluenceCredentials.Username
	$Confluencepasswordencrypted = $Global:Config.ConfluenceCredentials.PasswordSecureString | ConvertTo-SecureString

	$ConfluenceCreds = New-Object System.Management.Automation.PSCredential($Confluenceuser,$Confluencepasswordencrypted)

	$ConfluenceCredsPassword = $ConfluenceCreds.GetNetworkCredential().Password

	$Global:Confluencecreds = [Convert]::ToBase64String(
     [Text.Encoding]::UTF8.GetBytes("$($ConfluenceCreds.UserName):$ConfluenceCredsPassword")
   	)
}
function getConfluencePage()
{
<#
.SYNOPSIS
    Get a Confluence page information and return as JSON
#>
    $uri = $Global:Config.ConfluenceInformations.BaseURL + $Global:Config.ConfluenceInformations.EndpointAPI + $Global:Config.ConfluenceInformations.PageID;	

    $headers = @{
        "Authorization"="Basic "+$Global:Confluencecreds
        "X-Atlassian-Token"="no-check"
        "Content-Type"="application/json"
    }

    try {
		$result = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers
		Write-Host "Get Confluence page OK !" -ForegroundColor Green
        return $result
    }
    catch {
        Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription  
    }

}
function updateConfluencePage($page_version,$page_content)
{
<#
.SYNOPSIS
	Update a Confluence page with new content
.PARAMETER page_version
	New version number for the page
.PARAMETER page_content
	New content of the page
#>
    $uri = $Global:Config.ConfluenceInformations.BaseURL + $Global:Config.ConfluenceInformations.EndpointAPI + $Global:Config.ConfluenceInformations.PageID;	

    $headers = @{
        "Authorization"="Basic "+$Global:Confluencecreds
        "X-Atlassian-Token"="no-check"
        "Content-Type"="application/json"
    }

    $data = @{
        "id"    = $Global:Config.ConfluenceInformations.PageID
        "type" = "page"
        "title"   = $Global:Config.ConfluenceInformations.PageTitle
        "space" = 
            @{
                "key" = $Global:Config.ConfluenceInformations.PageSpace
            }
        "body" = 
            @{
                "storage" =  @{
                        "value" = $page_content
                        "representation"="storage"
                    }
            }       
        "version" =
            @{
                "number" = $page_version
            }
    }
    
    $body = $data | ConvertTo-Json -Depth 5

    try {
		Invoke-RestMethod -Uri $uri -Method PUT -Body $body -Headers $headers 
		Write-Host "Update Confluence page OK" -ForegroundColor Green   
    }
    catch {
        Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription  
    }
}

########### -------- MAIN -------- ###########

Write-Host "Checking requirements...."  -ForegroundColor Yellow

loadConfig

$requirementStatus = checkRequirements
if ($requirementStatus -eq 0)
{

	loadCredentialsWindows
	loadCredentialsConfluence
	$content = exportCSVandCreateHTML

	$confluencePageFull = getConfluencePage

	$confluencePageNewVersion = $confluencePageFull.version.number + 1

	$htmlWarning = '<ac:structured-macro 
		ac:macro-id="5b0783e9-35e8-4c92-93be-86ea86e7efcb" 
		ac:name="info" 
		ac:schema-version="1">
		<ac:parameter ac:name="title">Informations</ac:parameter>
		<ac:rich-text-body>
			<p>This page is updated automatically using a script. Any manual changes will be lost</p>
		</ac:rich-text-body>
		</ac:structured-macro>'

	$confluencePageNewContent = $htmlWarning + $content
	
	updateConfluencePage -page_version $confluencePageNewVersion -page_content $confluencePageNewContent
	
} 
else 
{
    write-host "Missing powershell module. You need to install the AD module !"
}