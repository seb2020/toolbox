# ..######.
# .##....##
# .##......
# ..######.
# .......##
# .##....##
# ..######.

<#
.SYNOPSIS
    Use HAProxy CSV to build a XML
.DESCRIPTION
    Monitoring HAProxy with PRTG
.NOTES
    File Name      : monitoring_HAProxy_PRTG.ps1
    Based on : http://lazic.info/josip/post/monitor-haproxy-via-prtg/ by Josip Lazic
#>

param(
	[string]$url,
	[string]$monitor
	);
	
$templates =@{
	standard = "qcur,smax,scur,smax,slim,stot,bin,bout";
	responses = "hrsp_1xx,hrsp_2xx,hrsp_3xx,hrsp_4xx,hrsp_5xx,hrsp_other,req_rate,req_rate_max,req_tot";
	errors = "dreq,dresp,ereq,econ,eresp,chkfail";
}
	
#Exit if no URL given
if ($url -eq "") {
	Write-Host "<prtg><error>1</error><text>Give me some URL</text></prtg>"
	Exit
}

#Default monitoring
if ($monitor -eq "" -or $monitor -eq "standard") {
	$monitor = $templates.standard
} elseif ($monitor -eq "responses") {
	$monitor = $templates.responses
} elseif ($monitor -eq "errors") {
	$monitor = $templates.errors
}
	
$names=@{
	pxname = "Proxy Name";
	svname = "Service name";
	qcur = "Current queue";
	qmax = "Maximum queue";
	scur = "Current sessions";
	smax = "Maximum sessions";
	slim = "Session limit";
	stot = "Sessions total";
	bin = "Bytes In";
	bout = "Bytes Out";
	dreq = "Denied requests";
	dresp = "Denied responses";
	ereq = "Request errors";
	econ = "Error connections";
	eresp = "Error responses";
	wretr = "Connections retries";
	wredis = "Redispatches";
	status = "Status";
	weight = "Weight";
	act = "Active servers";
	bck = "Backup servers";
	chkfail = "Failed checks";
	chkdown = "Downed";
	lastchg = "Since last down";
	downtime = "Downtime";
	qlimit = "Queue limit";
	pid = "PID";
	iid = "Unique ID";
	sid = "Server ID";
	rate = "Session rate";
	rate_lim = "Session rate limit";
	rate_max = "Max. session rate";
	check_status = "Check status";
	check_code = "Check code";
	check_duration = "Check duration";
	hrsp_1xx = "HTTP 1xx";
	hrsp_2xx = "HTTP 2xx";
	hrsp_3xx = "HTTP 3xx";
	hrsp_4xx = "HTTP 4xx";
	hrsp_5xx = "HTTP 5xx";	
	hrsp_other = "HTTP Other";
	req_rate = "HTTP request rate";
	req_rate_max = "Max HTTP request rate";
	req_tot = "Total HTTP requests";
}

$units=@{
	qcur = "Count";
	qmax = "Count";
	scur = "Count";
	smax = "Count";
	slim = "Count";
	stot = "Count";
	bin = "BytesBandwidth";
	bout = "BytesBandwidth";
	dreq = "Count";
	dresp = "Count";
	ereq = "Count";
	econ = "Count";
	eresp = "Count";
	wretr = "Count";
	wredis = "Count";
	status = "Count";
	weight = "Custom";
	act = "Count";
	bck = "Count";
	chkfail = "Count";
	chkdown = "Count";
	lastchg = "TimeSeconds";
	downtime = "TimeSeconds";
	qlimit = "Count";
	pid = "Custom";
	iid = "Custom";
	sid = "Custom";
	rate = "Count";
	rate_lim = "Count";
	rate_max = "Count";
	check_status = "Custom";
	check_code = "Custom";
	check_duration = "TimeSeconds";
	hrsp_1xx = "Count";
	hrsp_2xx = "Count";
	hrsp_3xx = "Count";
	hrsp_4xx = "Count";
	hrsp_5xx = "Count";
	hrsp_other = "Count";
	req_rate = "Count";
	req_rate_max = "Count";
	req_tot = "Count";
}

$monitorlist = $monitor.Split(",")

$webclient = New-Object System.Net.WebClient

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$content = $webclient.DownloadString($url)

$csv = $content | ConvertFrom-CSV -Header pxname,svname,qcur,qmax,scur,smax,slim,stot,bin,bout,dreq,dresp,ereq,econ,eresp,wretr,wredis,status,weight,act,bck,chkfail,chkdown,lastchg,downtime,qlimit,pid,iid,sid,throttle,lbtot,tracked,type,rate,rate_lim,rate_max,check_status,check_code,check_duration,hrsp_1xx,hrsp_2xx,hrsp_3xx,hrsp_4xx,hrsp_5xx,hrsp_other,hanafail,req_rate,req_rate_max,req_tot,cli_abrt,srv_abrt,comp_in,comp_out,comp_byp,comp_rsp,lastsess,last_chk,last_agt,qtime,ctime,rtime,ttime

Write-Host "<prtg>"
$csv | Foreach-Object {
	foreach ($m in $monitorlist) {
		$value = $_.($m)
		$unit = $units.($m)
		#if ($value -eq "") { continue } #Do not report empty values
		if ($value -eq "") { $value = 0 }
		Write-Host "<result>"
		Write-Host "<channel>"$_.pxname - $_.svname - $names.($m)"</channel>"
		Write-Host "<value>"$value"</value>"
		Write-Host "<unit>"$unit"</unit>"
		Write-Host "</result>"
	}
}
Write-Host "</prtg>"