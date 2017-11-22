# CopyNewlyCreatedFiles, Monitors created files and copies them
# Create a scheduled task, Trigger on system startup, Action powershell with an argument like -NoExit E:\Scripts\CopyNewlyCreatedFiles.ps1
# Tony Gustafsson 2017-11-22

$sourcePath = "C:\inetpub\mailroot\Queue";
$filter = "*.*";
$recursive = $false;

$fileWatcher = New-Object IO.FileSystemWatcher $sourcePath, $filter -Property @{
	IncludeSubdirectories = $recursive
	NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite'
}

$onCreated = Register-ObjectEvent $fileWatcher Created -SourceIdentifier CopyNewlyCreatedFiles -Action {
	$path = $Event.SourceEventArgs.FullPath;
	$name = $Event.SourceEventArgs.Name;
	$changeType = $Event.SourceEventArgs.ChangeType;
	$extensionArray = $name.Split('.');
	$extension = $extensionArray[$extensionArray.length - 1];
	$copyTo = "C:\inetpub\mailroot\QueueArchive\" + $(Get-Date -format "yyyy-MM-dd HHmmss") + "." + $extension;
	
	Write-Host $copyTo;
	Write-Host "The file '$name' was $changeType.";
	
	Copy-Item $path -Destination $copyTo -Force;
}
