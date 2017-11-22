###### USER DEFINED SETTINGS ######
$urls = @(
	"http://www.google.se";
	"http://www.google.com";
	"http://www.google.cn"
);
$match = "TriggerWord"; 	   #Google Analytics code, or anything else in the HTML output that has to be there to be OK
$timeout = 20;                	#In seconds before failure
$allow_redirection = $false;    #Is it OK to be redirected?
$cred = New-Object System.Net.NetworkCredential("user", "pass", "domain"); #false if not used
$server = "server1.domain.com"; #The server that will recieve the PowerShell remoting command
$fix = Restart-Service 'SERVICENAME' -force; #What will happen on the server if the URLs could not be loaded?

[int]$hour = $(Get-Date -format HH);
[int]$dayOfWeek = $(Get-Date).DayOfWeek.value__;
$timerule = ($hour -lt 8 -or $hour -gt 17) -or $dayOfWeek -gt 5; #Outside work hours, or just set to "true" if it always should restart service

$restartService = $false;
    
foreach ($url in $urls)
{
    $req = [System.Net.HttpWebRequest]::Create($url);
    $req.Timeout = ($timeout * 1000);
    $req.AllowAutoRedirect = $allow_redirection;

    if ($cred) {
        #Use credentials if not false
        $req.Credentials = $cred;
    }

    #Get the webpage to a variable
    try {
        $sw = [Diagnostics.Stopwatch]::StartNew(); #Measure time

        $res = $req.GetResponse();
        $responseStream = $res.getResponseStream();
        $sr = new-object IO.StreamReader($responseStream);
        $result = $sr.ReadToEnd();
        $sr.close();

        if ($result.Contains($match)) {
            Write-Host "Success! Got $url in $($sw.Elapsed.Milliseconds) ms";
        }
        else {
            Write-Host "Failure! The page $url did not contain the keyword ($match). Wrong site? Execution time: $($sw.Elapsed.Milliseconds) ms";
            $restartService = $true;
        }

        $sw.Stop();
        $sw.Elapsed;
        
        $res.Close();
    }
    catch {
        Write-Host "Failure! The page $url could not be downloaded!";
        $restartService = $true;
    }
}

if ($restartService)
{
    if ($timerule)
    {
        Invoke-Command -ComputerName $server -ScriptBlock { $fix }
    }
}

exit;