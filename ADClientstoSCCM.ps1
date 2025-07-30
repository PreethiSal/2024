#Please refer to the readme.txt file at F:\SCCM_Schedules\AD2SMS\readme.txt for more details on naps pw access process.


[Net.ServicePointManager]::SecurityProtocol = "Tls, Tls11, Tls12"
#funtion for sending error details by email

	function emailit($subx,$bodyx)
	{
	send-mailmessage -to cmalert@list.ti.com -from SCCM_AD_Disc_client@ti.com -smtpserver smtp.mail.ti.com -body $bodyx -subject $subx
	}

#Function to Trim the CanonicalName
    function Trim($Dump){
    foreach($x in $Dump){
                $name=$x.name
                $trimmed=($x.canonicalname) -replace "/$name",""
                $x.CanonicalName=$trimmed
               }}

	$sub = "AD to SCCM - Workstations Import Summary DLESSCCM01"


    $ENT=Get-ADComputer -server "ent.ti.com" -Filter 'OperatingSystem -notlike "*Server*"'  -properties  name,CanonicalName,OperatingSystem,operatingsystemversion,DNSHostName,lastLogOn,pwdlastset,
                whenCreated,OperatingSystemservicepack  | select name,CanonicalName,DNSHostName,OperatingSystem,operatingsystemversion,OperatingSystemservicepack,
				@{Name='lastlogon';Expression={[datetime]::FromFileTime($_."lastlogon")}},@{Name='pwdlastset';Expression={[datetime]::FromFileTime($_."pwdlastset")}},whencreated
                Trim($ENT)


#SEG.ti.com
    $user="ent\sccmpvreader"
	$tss_status= tss status
	If($tss_status -eq 'Not Connected'){
		tss init --url https://naps.itg.ti.com/ -r $env:SDKNAME -k $env:SDKKEY -e
	}
    $pw= tss secret -s 246177 -f password
    $securePassword_pv = ConvertTo-SecureString $pw -AsPlainText -Force
    $Cred=New-Object System.Management.Automation.PSCredential -argumentlist ($user,$securePassword_pv)
    $serviceacct_seg = "SEG\smssqlsvc_seg"
    $api = "https://naps.itg.ti.com/winauthwebservices/api/v1"
    $endpoint_seg = "$api/secrets/66955/fields/password"
    $response_seg = Invoke-RestMethod $endpoint_seg -credential $cred -method Get
    
    if ($response_seg.Contains(" "))
    {
    Send-MailMessage -From "SCCM_AD_Disc_client@ti.com" -To "cmalert@list.ti.com" -Subject "Failed to get Password for $serviceacct_seg from PV. Script terminated" 
	-Body "End of message" -SmtpServer smtp.mail.ti.com
	Exit
    }

	$securePassword_seg = ConvertTo-SecureString $response_seg -AsPlainText -Force
	$cred_seg = New-Object System.Management.Automation.PSCredential -ArgumentList ($serviceacct_seg,$securePassword_seg)
	try
	{
	$SEG =  Get-ADComputer -server "seg.ti.com" -Filter 'OperatingSystem -notlike "*Server*"' -Credential $cred_seg -properties  name,CanonicalName,OperatingSystem,operatingsystemversion,DNSHostName,lastLogOn,pwdlastset,
                whenCreated,OperatingSystemservicepack  | select name,CanonicalName,DNSHostName,OperatingSystem,operatingsystemversion,OperatingSystemservicepack,
				@{Name='lastlogon';Expression={[datetime]::FromFileTime($_."lastlogon")}},@{Name='pwdlastset';Expression={[datetime]::FromFileTime($_."pwdlastset")}},whencreated

            Trim($SEG)
            }
    catch
	{
	$Sub = "Error in AD Discovery_Workstations Script DLESSCCM01-SEG"
	$errorMessage = $_.Exception.Message
	$FailedItem = $_.Exception.ItemName
	emailit $sub $errormessage
	write-host $errormessage
	write-host $FailedItem
	}
#"AD Queried" 
$ss=$ENT+$SEG

$sqlcmd1="truncate table SMS_AD_OU_Discovery"
Invoke-Sqlcmd -Database TIDB -Query $sqlcmd1 -ServerInstance DLESSCCM01
foreach ($s in $ss)
{
$cname=$s.name
$cou=$s.CanonicalName
$cDnsName=$s.DNSHostName
$cos=$s.OperatingSystem
$csp=$s.OperatingSystemservicepack
$clastlogon=$s.lastlogon
$lastpwd=$s.pwdlastset
$whencr=$s.whencreated
$osbuild=$s.operatingsystemversion

$sqlcmd = "INSERT INTO SMS_AD_OU_Discovery (name0,OU,DNS,OS,SP,OSversion,LastLogon,LastPwdSet,WhenCreated) VALUES ('$cname','$cou','$cDnsName','$cos','$csp','$osbuild','$clastlogon','$lastpwd','$whencr')"
try{
Invoke-Sqlcmd -Database TIDB -Query $sqlcmd -ServerInstance DLESSCCM01
}
catch{
    
	$errorMessage = $_.Exception.Message
	$FailedItem = $_.Exception.ItemName
	emailit $sub $errormessage
	write-host $errormessage
	write-host $FailedItem
	
}
}

$db = Invoke-Sqlcmd -Database TIDB -Query "select count(name0) as Count from SMS_AD_OU_Discovery"  -ServerInstance DLESSCCM01
#$odb = Invoke-Sqlcmd -Database TIDB -Query "select count(name0) as Count from SMS_AD_OU_Discovery"  -ServerInstance DLESSCCM01
#$odbcount = $odb.Count
$dbcount = $db.Count
$adcount = $ss.count
$body = [string]$adcount + "  Records in AD.    " + [string]$dbcount + "  Records on DLESSCCM01 Database." #+ "  Previous import: " + [string]$odbcount + " Records "
emailit $sub $body


