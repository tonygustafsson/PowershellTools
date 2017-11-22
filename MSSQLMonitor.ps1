$servers = @("server1.domain.com", "server2.domain.com", "server3.domain.com");
$samples = 5;

foreach ($server in $servers) {
	$instanceName = Invoke-Command -ComputerName $server -ScriptBlock { $(Get-Counter -ListSet *:Workload*).CounterSetName };
	$instanceName = $instanceName.Split(":")[0];

	Write-Host "Getting statistics from $server with instance name $instanceName...";
	
	$avgWaitTime 		= $instanceName + ":Locks(_Total)\Average Wait Time (ms)";
	$numDeadlocks 		= $instanceName + ":Locks(_Total)\Number of Deadlocks/sec";
	$transactions 		= $instanceName + ":Databases(_Total)\Transactions/sec";
	$batchRequests 		= $instanceName + ":SQL Statistics\SQL Compilations/sec";
	$sqlCompilations 	= $instanceName + ":SQL Statistics\Batch Requests/sec";
	$userConnections 	= $instanceName + ":General Statistics\User Connections";

	$avgWaitTimeSum = 0;
	$numDeadlocksSum = 0;
	$transactionsSum = 0;
	$batchRequestsSum = 0;
	$sqlCompilationsSum = 0;
	$userConnectionsSum = 0;

	Get-Counter -ComputerName $server -Counter $avgWaitTime -MaxSamples $samples | Foreach {
		$currentValue = [int]$_.CounterSamples[0].CookedValue;
		$avgWaitTimeSum = $avgWaitTimeSum + $currentValue;
	}

	Get-Counter -ComputerName $server -Counter $numDeadlocks -MaxSamples $samples | Foreach {
		$currentValue = [int]$_.CounterSamples[0].CookedValue;
		$numDeadlocksSum = $numDeadlocksSum + $currentValue;
	}

	Get-Counter -ComputerName $server -Counter $transactions -MaxSamples $samples | Foreach {
		$currentValue = [int]$_.CounterSamples[0].CookedValue;
		$transactionsSum = $transactionsSum + $currentValue;
	}

	Get-Counter -ComputerName $server -Counter $batchRequests -MaxSamples $samples | Foreach {
		$currentValue = [int]$_.CounterSamples[0].CookedValue;
		$batchRequestsSum = $batchRequestsSum + $currentValue;
	}

	Get-Counter -ComputerName $server -Counter $sqlCompilations -MaxSamples $samples | Foreach {
		$currentValue = [int]$_.CounterSamples[0].CookedValue;
		$sqlCompilationsSum = $sqlCompilationsSum + $currentValue;
	}

	Get-Counter -ComputerName $server -Counter $userConnections -MaxSamples 1 | Foreach {
		$currentValue = [int]$_.CounterSamples[0].CookedValue;
		$userConnectionsSum = $userConnectionsSum + $currentValue;
	}

	Write-Host "Total wait time: " ($avgWaitTimeSum / $samples);
	Write-Host "Total deadlocks: " ($numDeadlocksSum / $samples);
	Write-Host "Total transactions: " ($transactionsSum / $samples);
	Write-Host "Total batch requests: " ($batchRequestsSum / $samples);
	Write-Host "Total sql compilations: " ($sqlCompilationsSum / $samples);
	Write-Host "Total user connections: " $userConnectionsSum;
}
