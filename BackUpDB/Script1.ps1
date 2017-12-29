##################################################################################################
# Скрипт резервного копирования БД PostgreSQL
##################################################################################################
Try
{
$whereLocateFolderBackUpDB = "c:\tmp\db" # Указать и СОЗДАТЬ папку для базы данных
$whereLocateJsonSettings = "c:\ProgramData\Falcongaze SecureTower\BackUpDB" 
$PostgreCompress = "-Fc"


Get-Childitem env:
Get-Childitem env:computername 
$dateLastRotation = Get-Date -DisplayHint Date
$prevDbType = [Environment]::GetEnvironmentVariable("FGST_PREVIOUS_DB_TYPE");
$prevDbID = [Environment]::GetEnvironmentVariable("FGST_PREVIOUS_DB_ID");
$prevDbConnString = [Environment]::GetEnvironmentVariable("FGST_PREVIOUS_DB_CONNECTION_STRING");
$currDbType = [Environment]::GetEnvironmentVariable("FGST_CURRENT_DB_TYPE");
$currDbID = [Environment]::GetEnvironmentVariable("FGST_CURRENT_DB_ID");
$currDbConnString = [Environment]::GetEnvironmentVariable("FGST_CURRENT_DB_CONNECTION_STRING");
$properties = @{
				'whereLocateFolderBackUpDB' = $whereLocateFolderBackUpDB;
                'prevDbType' 				= $prevDbType;
                'PostgreCompress'			= $PostgreCompress
				'prevDbID' 					= $prevDbID;
				'prevDbConnString' 			= $prevDbConnString;
                'dateLastRotation' 			= $dateLastRotation.ToString()
				'currDbType' 				= $currDbType;
				'currDbID' 					= $currDbID;
				'currDbConnString' 			= $currDbConnString;
				} 
$obj = New-Object -TypeName PSObject -Prop $properties

############################################################################

$obj | ConvertTo-Json | Out-File $whereLocateJsonSettings"\settings.json" 
$obj | ConvertTo-Json | Out-File $whereLocateJsonSettings"\settingsCurrentDb.json" 
}
Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    $ErrorMessage | Out-File $whereLocateJsonSettings"\error1.txt";
    $FailedItem  | Out-File $whereLocateJsonSettings"\error2.txt";
}
exit
	
	

