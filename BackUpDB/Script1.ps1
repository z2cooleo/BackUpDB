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
function Escape-JSONString($str){
	if ($str -eq $null) {return ""}
	$str = $str.ToString().Replace('"','\"').Replace('\','\\').Replace("`n",'\n').Replace("`r",'\r').Replace("`t",'\t')
	return $str;
}

function ConvertTo-JSON($maxDepth = 4,$forceArray = $false) {
	begin {	$data = @()	}
	process{ $data += $_ }	
	end{	
		if ($data.length -eq 1 -and $forceArray -eq $false) {$value = $data[0]} 
		else {	$value = $data	}
		if ($value -eq $null) {	return "null"}
		$dataType = $value.GetType().Name		
		switch -regex ($dataType) {
	            'String'  {	return  "`"{0}`"" -f (Escape-JSONString $value ) }
	            '(System\.)?DateTime'  {return  "`"{0:yyyy-MM-dd}T{0:HH:mm:ss}`"" -f $value}
	            'Int32|Double' {return  "$value"}
				'Boolean' {return  "$value".ToLower()}
	            '(System\.)?Object\[\]' { if ($maxDepth -le 0){return "`"$value`""}					
					$jsonResult = ''
					foreach($elem in $value){
						if ($jsonResult.Length -gt 0) {$jsonResult +=', '}				
						$jsonResult += ($elem | ConvertTo-JSON -maxDepth ($maxDepth -1))}
					return "[" + $jsonResult + "]"}
				'(System\.)?Hashtable' { # hashtable
					$jsonResult = ''
					foreach($key in $value.Keys){
						if ($jsonResult.Length -gt 0) {$jsonResult +=', '}
						$jsonResult += 
@"
	"{0}": {1}
"@ -f $key , ($value[$key] | ConvertTo-JSON -maxDepth ($maxDepth -1) )
					}
					return "{" + $jsonResult + "}"
				}
	            default { #object
					if ($maxDepth -le 0){return  "`"{0}`"" -f (Escape-JSONString $value)}
					
					return "{" +
						(($value | Get-Member -MemberType *property | % { 
@"
	"{0}": {1}
"@ -f $_.Name , ($value.($_.Name) | ConvertTo-JSON -maxDepth ($maxDepth -1) )			
					
					}) -join ', ') + "}"}}}}
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
	
	

