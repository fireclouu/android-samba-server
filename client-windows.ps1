param (
	[string]$IP
)

function ChallengeRemote {
	try {
		$client = New-Object System.Net.Sockets.TcpClient("$IP", 9000)
		$client.Close()
	} catch {
		Write-Host "Network timed-out" -Foregroundcolor Red
		exit 1
	}
}

function MapNetworkGlobal {
	param (
		[string]$DriveName,
		[string]$Root,
		[PSCredential]$Credential
	)
	
	Write-Host "Trying to bind `"${DriveName}`" to `"${Root}...`"" -ForegroundColor Yellow
	if (Get-PSDrive -Name "$DriveName" -ErrorAction SilentlyContinue) {
		Write-Host "`nFound existing binding, removing by force..."
		[void](net use "${DriveName}:" /delete /yes)
		Remove-PSDrive -Name "$DriveName" -Force -ErrorAction SilentlyContinue
	}
	try {
		New-PSDrive -Name "$DriveName" -PSProvider FileSystem -Root "$Root" -Credential $Credential -Persist -Scope Global | Out-Null
	} catch {
		Write-Host "Unable to bind ${DriveName}." -ForegroundColor Red
		exit 1
	} 
	Write-Host "Binding `"$DriveName`" Success!" -ForegroundColor Green
}

Write-Host "TERMUX Samba Script: CLIENT" -ForegroundColor Yellow

# disable lanmanserver, dont kill proc, let user reboot its system
$service = Get-Service -Name LanmanServer -ErrorAction SilentlyContinue

if ($service -and $service.Status -eq 'Running') {
	Write-Host "Disabling local samba server..."
	Start-Process cmd -Verb runas -ArgumentList ('/c powershell /c  Set-Service -Name LanmanServer -StartupType Disabled') -Wait
	Write-Host "Please reboot your device." -ForegroundColor Yellow
	Read-Host
	exit 0
}



if ([string]::IsNullOrEmpty($IP)) {
	$IP = Read-Host "Input server IP"
	if ([string]::IsNullOrEmpty($IP)) {
		Write-Host "ERROR: Please supply IP Address by using -IP xxx.xxx.xxx.xxx" -ForegroundColor Red
		Start-Sleep -Seconds 3
	exit 1
	}
}

Write-Host "Trying to talk with $IP..."	-ForegroundColor Yellow

# first challenge
ChallengeRemote

Start-Sleep -Seconds 2

# 2nd communication
try {
	$client = New-Object System.Net.Sockets.TcpClient("$IP", 9000)
} catch {
	Write-Host "Network timed-out" -Foregroundcolor Red
	exit 1
}

$stream = $client.GetStream()
$reader = New-Object System.IO.StreamReader($stream)
# $writer = New-Object System.IO.StreamWriter($stream)
# $writer.Flush()
# $writer.Close()

# fetch credentials
$username = $reader.ReadLine()
$client.Close()

Write-Host "Server username: $username" -ForegroundColor Green


$isAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# for netsh
if (-not $isAdmin) {
	$argWait = 'Start-Sleep -Seconds 1'
	$args0 = "Write-Output 'Clearing localhost port forward bindngs...'"
	$args1 = "Write-Output 'Forwarding $IP samba ports to localhost 445, 139...'"
	$args2 = "netsh interface portproxy add v4tov4 listenport=445 connectport=4445 connectaddress=$IP"
	$args3 = "netsh interface portproxy add v4tov4 listenport=139 connectport=1139 connectaddress=$IP"
	$args4 = 'netsh interface portproxy reset'
	Start-Process cmd -Verb RunAs -ArgumentList ('/c powershell /c "', $args0, '; ', $argWait, '; ',  $args4, '; ', $args1, '; ', $args2, '; ', $args3, '; ', $argWait, '; ', '"') -Wait
}

Write-Host "Input server password: " -ForegroundColor Yellow
$password = Read-Host -AsSecureString
$credential = New-Object System.Management.Automation.PSCredential($username, $password)

# clear existing sessions
# net use * /delete /yes

MapNetworkGlobal -DriveName "Z" -Root '\\localhost\android-termux' -Credential $credential
MapNetworkGlobal -DriveName "Y" -Root '\\localhost\android-internal' -Credential $credential

# final challenge
ChallengeRemote

Write-Host "Server binded successfully!" -ForegroundColor Green
Start-Sleep -Seconds 1
Start-Process explorer "shell:MyComputerFolder"