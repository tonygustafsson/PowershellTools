# Sends email when detecting HTTP 500 in IIS
# Dependency on Log Parser 2.2
# This example only looks at /api/*

$numberOfErrors = & "C:\Program Files (x86)\Log Parser 2.2\logparser" "Select COUNT(*) as NumberOfErrors From E:\Logs\IIS\W3SVC1\u_ex*.log WHERE sc-status = 500 AND cs-uri-stem LIKE '/api/%'" -stats:OFF -q:ON

echo "Number of errors found: ${numberOfErrors}."

if ($numberOfErrors -gt 0)
{
	$report = & "C:\Program Files (x86)\Log Parser 2.2\logparser" -rtp:-1 "Select date as Date, time as Time, sc-status as Status, sc-substatus as Substatus, s-ip as IP, cs-method as Method, cs-uri-stem as URL, cs-uri-query as Query, s-port as Port, time-taken as ExecTime From E:\Logs\IIS\W3SVC1\u_ex*.log WHERE sc-status = 500 AND cs-uri-stem LIKE '/api/%'";
	
	echo "Sending the following report:";
	echo $report;
	
	$report = $report -replace "$","<br>";
	$from = "noreply@error.com";
	[string[]]$to = "You <your@mail.com>", "ThatPerson <that.person@mail.com>";
	$subject = "Found ${numberOfErrors} errors in API";
	$body = "These errors were found:<br><br>${report}";
	
 	Send-MailMessage -SmtpServer localhost -From $from -To $to -Subject $subject -Body $body -BodyAsHtml;
}