# Created by Tony Gustafsson
# Version 1.0
# Release date 2012-05-23

###### USER DEFINED SETTINGS ######
$olderThan		= 	30;					#Remove profiles older than X days
$match 			= 	"hm.";				#Only remove profiles with a username containing this value
$source_name	= 	"DeletedProfiles"; 	#The source name in event monitor

if (![System.Diagnostics.EventLog]::SourceExists($source_name)) {
	#Create the source name if it's not created in the event viewer
    [System.Diagnostics.EventLog]::CreateEventSource($source_name, "Application") 
}

Write-Host "Beginning to remove old profiles...";
Write-EventLog -logname Application -Source $source_name -eventID 1 -entrytype Information -message "Beginning to remove old profiles...";

Get-WmiObject -Class Win32_UserProfile -Computer "localhost" -ea 0  |
Foreach-Object {
	if ($_.LastUseTime -and $_.LocalPath -and $_.Special -ne $true) {
		$loggedIn = $_.LastUseTime.SubString(0,8);
		$time = [datetime]::ParseExact($loggedIn, "yyyyMMdd", $null);
		$username = $_.LocalPath.Split("\\")[2];

		if ($time -lt ($(Get-Date).AddDays($olderThan * -1)) -eq $true -and $username.Contains($match)) {
			Write-Host "Deleting $username, last logged on $time";
			Write-EventLog -logname Application -Source $source_name -eventID 1 -entrytype Information -message "Deleting $username, last logged on $time";
			
			$_.Delete();
			if ((Test-Path -path $_.LocalPath) -eq $true) {
				#Sometimes the directory isn't totally deleted, try to remove it completely
				Remove-Item $_.LocalPath;
			}
		}
	}
}