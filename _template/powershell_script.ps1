
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

########### -------- Functions -------- ###########

function loadConfig
{
<#
.SYNOPSIS
    Load config file
#>
	try {
		$global:Config = Get-Content "powershell_config.json" -Raw -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue | ConvertFrom-Json -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue
	} catch {
		Write-Host -Message "The Base configuration file is missing!"
	}

	# Check the configuration
	if (!($Config)) {
		Write-Host -Message "The Base configuration file is missing!"
	}
}

########### -------- MAIN -------- ###########


    loadConfig

    Write-Host "Ticket simple" -ForegroundColor green
    $Global:Config.Tickets_simple | ForEach-Object {
        $title = $_.title
        $_.description | ForEach-Object {
            $description = $_
            Write-Output "Ticket title: $title"
            Write-Output "Ticket description: $description"

        }
    }
    Write-Host "End ticket complex" -ForegroundColor green

    $Global:Config.Tickets_complex | ForEach-Object {
        $title = $_.title
        $_.data | ForEach-Object {
            $description = $_.Description
            $field1 = $_.Field1
            Write-Output "Ticket title: $title"
            Write-Output "Ticket data description: $description"
            Write-Output "Ticket data field: $field1"

        }
    }