# ..######.
# .##....##
# .##......
# ..######.
# .......##
# .##....##
# ..######.

<#
.SYNOPSIS
    Script to create collection in SCCM 2012 with rule based on a AD group
.DESCRIPTION
     CSV file format : "CollectionName","CollectionLimit","QueryName","QueryWQL","DayInterval","ContainerID"
.NOTES
    File Name      : CreateCollectionSCCM.ps1

#>



$Server = "10.1.1.5"
$NameSpace = "root\sms\site_c01"
$LimitToCollectionID = "SMS00001"
$ContainerID = ""  	
$NewCollectionName = "XXX_XXX_TEST Script"
$DayInterval = 7
$QueryName = "Query test"

#Ajoute la query contenu dans le fichier csv a la requete du même nom
function AddQueryRuleToCollection($CollectionName, $RuleName, $WQL)
{
    $wmiclass = "\\" + $Server + "\" + $NameSpace + ":sms_CollectionRuleQuery"
    $QueryToCreated = ([wmiclass] $wmiclass).CreateInstance()
    $QueryToCreated.QueryExpression = $WQL
    $QueryToCreated.RuleName = $RuleName
    $CollectionToAddQuery = Get-WmiObject SMS_Collection -namespace $Namespace -computer $server | where-object { $_.Name -eq $CollectionName }
    $CollectionToAddQuery.AddMembershipRule($QueryToCreated)
}

function CreateCollection($CollectionLimitID, $Name, $DayInterval, $ContainerID)
{
	$Path = "\\" + $Server + "\" + $NameSpace + ":SMS_Collection"
	$CollectionToCreate = ([wmiclass] $path).CreateInstance()
	$CollectionToCreate.Name = $Name
	$CollectionToCreate.LimitToCollectionID = $CollectionLimitID
	$Path = "\\" + $server + "\" + $Namespace + ":SMS_ST_RecurInterval"
	$refreshSchedule = ([wmiclass] $path).CreateInstance()
	$refreshSchedule.DaySpan = 7
	$refreshSchedule.StartTime = "20120804060000.000000+***"
	$CollectionToCreate.RefreshSchedule = $refreshSchedule
	$CollectionToCreate.RefreshType = 6
	
    #Ajout de la collection crée dans le dossier (en cours de test)
	#$FolderToAddCollection = Get-WmiObject SMS_ObjectContainerNode -namespace $Name -computer $server | where-object { $_.ContainerNodeId -eq $ContainerID }
	$FolderToAddCollection
	$CollectionToCreate.Put()
}

#Créer un dossier 
function CreateFolder($FolderName, $ParentFolderId)
{
	$Path = "\\" + $Server + "\" + $NameSpace + ":SMS_ObjectContainerNode"
	$FolderToCreate = ([wmiclass] $path).CreateInstance()
	$FolderToCreate.Name = $FolderName
	$FolderToCreate.ObjectType = 5000
	$FolderToCreate.ParentContainerNodeId = $ParentFolderId
	$FolderToCreate.Put()

}

#Charge les informations contenue dans le csv
function LoadData($InputFilePath)
{
    try
    {
        $header = "CollectionName","CollectionLimit","QueryName","QueryWQL","DayInterval","ContainerID"
        $headerStr = "CollectionName;CollectionLimit;QueryName;QueryWQL;DayInterval;ContainerID"
        
        # Read data from file
        $collectionCSV = Import-Csv -Path $InputFilePath -Header $header -Delimiter ";" 
        $colNum = ($collectionCSV | get-member -type NoteProperty).Count
    
        if(-not($colNum -eq 6))
        {
            Write-Error ("Invalid arguments number in " + $InputFilePath + ". Arguments must be : " + $headerStr)
            return $null
        }
    
        # Check data validity
        $line = 1
        $checkErrors = 0
        
        foreach($collection in $CollectionCSV)
        {
            # Group description and members can be empty
            if(-not ($collection.CollectionName) -or (-not($collection.CollectionLimit)) -or (-not($collection.QueryName)) -or (-not($collection.QueryWQL)) -or (-not($collection.DayInterval)))
            {
                Write-Warning ("An invalid entry was found in " + $InputFilePath + " at line " + $line + ". Please remove any blank line and complete missing attributes.")
                Write-Warning ("Valid entries format : " + $headerStr)
                $checkErrors++
            }
            
            $line++
        }
    
        if($checkErrors -gt 0)
        {
            Write-Error "Errors were found in CSV input file. Please correct them and try again."
            return $null
        }
        
        return $collectionCSV
    }
    catch 
    { 
        
        Write-Error ($_.Exception.GetType().ToString() + " : " + $_)
        Write-Error "Cannot get data from CSV input file. Please check input data."
        return $null
    }
}



#$QueryWQL = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'DJEVA\\APP_ERICards Computers'"
#CreateCollection $LimitToCollectionID $NewCollectionName $ContainerID $DayInterval
#AddQueryRuleToCollection $NewCollectionName $QueryName $QueryWQL
#CreateFolder "TestFolder" 16777219


$CollectionFromCSV = LoadData("collection.csv")

try
{    
    foreach($collection in $CollectionFromCSV)
    {
		#CreateFolder "Deployment" $collection.ContainerID
		CreateCollection $collection.CollectionLimit $collection.CollectionName $collection.ContainerID $collection.DayInterval
		AddQueryRuleToCollection $collection.CollectionName $collection.QueryName $collection.QueryWQL
    }
}
catch 
{ 
    Write-Error ($_.Exception.GetType().ToString() + " : " + $_)
    Write-Warning ("Rollback of created collection has to be done manually !")
    exit
}