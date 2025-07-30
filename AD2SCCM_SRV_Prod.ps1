#Please refer to the readme.txt file at F:\SCCM_Schedules\AD2SMS\readme.txt for more details on naps pw access process.

[Net.ServicePointManager]::SecurityProtocol = "Tls, Tls11, Tls12"
#function for sending error details by email 
function emailit($subx,$bodyx)
    {
    send-mailmessage -to cmalert@list.ti.com -from SCCM_AD_Disc_SRV@ti.com -smtpserver smtp.mail.ti.com -body $bodyx -subject $subx
    }
	
#Function to Trim the CanonicalName
function Trim($SRVdump){
foreach($x in $SRVdump){
                $name=$x.name
                $trimmed=($x.canonicalname) -replace "/$name",""
                $x.CanonicalName=$trimmed
               }

}

$sub = "Active Directory to SCCM - Server Import Summary - DLESSCCM01"
#Credentials for sccmpvreader service account 
 $user="ent\sccmpvreader"
	$tss_status= tss status
	If($tss_status -eq 'Not Connected'){
		tss init --url https://naps.itg.ti.com/ -r $env:SDKNAME -k $env:SDKKEY -e
	}
    $pw= tss secret -s 246177 -f password
    $securePassword_pv = ConvertTo-SecureString $pw -AsPlainText -Force
    $Cred=New-Object System.Management.Automation.PSCredential -argumentlist ($user,$securePassword_pv)

    #Querying Each Domain
    #TI.com
    try
    {
    $TISRV=Get-ADComputer -server "ti.com" -Filter 'OperatingSystem -like "*Server*"'  -properties  name,CanonicalName,OperatingSystem,operatingsystemversion,DNSHostName,lastLogOn,pwdlastset,
                whenCreated,OperatingSystemservicepack  | select name,CanonicalName,DNSHostName,OperatingSystem,operatingsystemversion,OperatingSystemservicepack,
				@{Name='lastlogon';Expression={[datetime]::FromFileTime($_."lastlogon")}},@{Name='pwdlastset';Expression={[datetime]::FromFileTime($_."pwdlastset")}},whencreated
			Trim($TISRV)
            
    }
    catch
    {
    $Sub = "Error in SRV Active Directory Discovery Script(DLESSCCM01) - TI.com"
    $errorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    emailit $sub $errormessage
    write-host $errormessage
    write-host $FailedItem
    }


    #ENT.TI.com
    try
    {
    $ENTSRV=Get-ADComputer -server "ent.ti.com" -Filter 'OperatingSystem -like "*Server*"'  -properties  name,CanonicalName,OperatingSystem,operatingsystemversion,DNSHostName,lastLogOn,pwdlastset,
                whenCreated,OperatingSystemservicepack  | select name,CanonicalName,DNSHostName,OperatingSystem,operatingsystemversion,OperatingSystemservicepack,
				@{Name='lastlogon';Expression={[datetime]::FromFileTime($_."lastlogon")}},@{Name='pwdlastset';Expression={[datetime]::FromFileTime($_."pwdlastset")}},whencreated

            Trim($ENTSRV)
		}
    catch
    {
    $Sub = "Error in SRV Active Directory Discovery Script(DLESSCCM01) - ENT.TI.com"
    $errorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    emailit $sub $errormessage
    write-host $errormessage
    write-host $FailedItem
    }
	
	#UTDS.LOCAL
	 try
    {
    $UTDSSRV=Get-ADComputer -server "utds.local" -Filter 'OperatingSystem -like "*Server*"'  -properties  name,CanonicalName,OperatingSystem,operatingsystemversion,DNSHostName,lastLogOn,pwdlastset,
                whenCreated,OperatingSystemservicepack  | select name,CanonicalName,DNSHostName,OperatingSystem,operatingsystemversion,OperatingSystemservicepack,
				@{Name='lastlogon';Expression={[datetime]::FromFileTime($_."lastlogon")}},@{Name='pwdlastset';Expression={[datetime]::FromFileTime($_."pwdlastset")}},whencreated

            Trim($UTDSSRV)
		}
    catch
    {
    $Sub = "Error in SRV Active Directory Discovery Script(DLESSCCM01) - UTDS.LOCAL"
    $errorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    emailit $sub $errormessage
    write-host $errormessage
    write-host $FailedItem
    }


    #PRE.prod.ead
    $serviceacct_pre = "pre\smssqlsvc_pre"
    $api = "https://naps.itg.ti.com/winauthwebservices/api/v1"
    $endpoint_pre = "$api/secrets/66948/fields/password"
    $response_pre = Invoke-RestMethod $endpoint_pre -credential $cred -method Get

    
    if ($response_pre.Contains(" "))
    {
    Send-MailMessage -From "SCCM_AD_Disc_SRV@ti.com" -To "cmalert@list.ti.com" -Subject "Failed to get Password for $serviceacct_pre from PV. Script terminated" -Body "End of message" -SmtpServer smtp.mail.ti.com
	Exit
    }

	$securePassword_pre = ConvertTo-SecureString $response_pre -AsPlainText -Force
	$cred_pre = New-Object System.Management.Automation.PSCredential -ArgumentList ($serviceacct_pre,$securePassword_pre)

    try{
    $PRESRV=Get-ADComputer -server "pre.prod.ead" -Credential $cred_pre -Filter 'OperatingSystem -like "*Server*"'  -properties  name,CanonicalName,OperatingSystem,operatingsystemversion,DNSHostName,lastLogOn,pwdlastset,
                whenCreated,OperatingSystemservicepack  | select name,CanonicalName,DNSHostName,OperatingSystem,operatingsystemversion,OperatingSystemservicepack,
				@{Name='lastlogon';Expression={[datetime]::FromFileTime($_."lastlogon")}},@{Name='pwdlastset';Expression={[datetime]::FromFileTime($_."pwdlastset")}},whencreated

            Trim($PRESRV)
            }
    catch
    {
    $Sub = "Error in SRV Active Directory Discovery Script(DLESSCCM01) - PRE"
    $errorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    emailit $sub $errormessage
    write-host $errormessage
    write-host $FailedItem
    }


    #XENT
    $serviceacct_xent = "XENT\smssqlsvc_xent"
    $api = "https://naps.itg.ti.com/winauthwebservices/api/v1"
    $endpoint_xent = "$api/secrets/66954/fields/password"
    $response_xent = Invoke-RestMethod $endpoint_xent -credential $cred -method Get
    
    if ($response_xent.Contains(" "))
    {
    Send-MailMessage -From "SCCM_AD_Disc_SRV@ti.com" -To "cmalert@list.ti.com" -Subject "Failed to get Password for $serviceacct_xent from PV. Script terminated" -Body "End of message" -SmtpServer smtp.mail.ti.com
	Exit
    }

	$securePassword_xent = ConvertTo-SecureString $response_xent -AsPlainText -Force
	$cred_xent = New-Object System.Management.Automation.PSCredential -ArgumentList ($serviceacct_xent,$securePassword_xent)
 
    try{
    $XENTSRV = Get-ADComputer -server "dlezvxad03.xent.ead" -Credential $cred_xent -Filter 'OperatingSystem -like "*Server*"'  -properties  name,CanonicalName,OperatingSystem,operatingsystemversion,DNSHostName,lastLogOn,pwdlastset,
                whenCreated,OperatingSystemservicepack  | select name,CanonicalName,DNSHostName,OperatingSystem,operatingsystemversion,OperatingSystemservicepack,
				@{Name='lastlogon';Expression={[datetime]::FromFileTime($_."lastlogon")}},@{Name='pwdlastset';Expression={[datetime]::FromFileTime($_."pwdlastset")}},whencreated

            Trim($XENTSRV)
			}
   catch
    {
    $Sub = "Error in SRV Active Directory Discovery Script(DLESSCCM01) - XENT"
    $errorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    emailit $sub $errormessage
    write-host $errormessage
    write-host $FailedItem
    }
	
	#SEG
	$serviceacct_seg = "SEG\smssqlsvc_seg"
    $api = "https://naps.itg.ti.com/winauthwebservices/api/v1"
    $endpoint_seg = "$api/secrets/66955/fields/password"
    $response_seg = Invoke-RestMethod $endpoint_seg -credential $cred -method Get
    
    if ($response_seg.Contains(" "))
    {
    Send-MailMessage -From "SCCM_AD_Disc_SRV@ti.com" -To "cmalert@list.ti.com" -Subject "Failed to get Password for $serviceacct_seg from PV. Script terminated" 
	-Body "End of message" -SmtpServer smtp.mail.ti.com
	Exit
    }

	$securePassword_seg = ConvertTo-SecureString $response_seg -AsPlainText -Force
	$cred_seg = New-Object System.Management.Automation.PSCredential -ArgumentList ($serviceacct_seg,$securePassword_seg)
 
    try{
    $SEGSRV = Get-ADComputer -server "SEG.TI.COM" -Credential $cred_seg -Filter 'OperatingSystem -like "*Server*"'  -properties  name,CanonicalName,OperatingSystem,operatingsystemversion,DNSHostName,lastLogOn,pwdlastset,
                whenCreated,OperatingSystemservicepack  | select name,CanonicalName,DNSHostName,OperatingSystem,operatingsystemversion,OperatingSystemservicepack,
				@{Name='lastlogon';Expression={[datetime]::FromFileTime($_."lastlogon")}},@{Name='pwdlastset';Expression={[datetime]::FromFileTime($_."pwdlastset")}},whencreated

            Trim($SEGSRV)
			   }
   catch
    {
    $Sub = "Error in SRV Active Directory Discovery Script(DLESSCCM01)-SEG"
    $errorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    emailit $sub $errormessage
    write-host $errormessage
    write-host $FailedItem
	}
	
	
	#JC
    $serviceacct_jc = "JC.ead\smssqlsvc_jc"
    $api = "https://naps.itg.ti.com/winauthwebservices/api/v1"
    $endpoint_jc = "$api/secrets/74065/fields/password"
    $response_jc = Invoke-RestMethod $endpoint_jc -credential $cred -method Get
    
    if ($response_jc.Contains(" "))
    {
    Send-MailMessage -From "SCCM_AD_Disc_SRV@ti.com" -To "cmalert@list.ti.com" -Subject "Failed to get Password for $serviceacct_jc from PV. Script terminated" 
	-Body "End of message" -SmtpServer smtp.mail.ti.com
	Exit
    }

	$securePassword_jc = ConvertTo-SecureString $response_jc -AsPlainText -Force
	$cred_jc = New-Object System.Management.Automation.PSCredential -ArgumentList ($serviceacct_jc,$securePassword_jc)
 
    try{
    $JCSRV = Get-ADComputer -server "jc.ead" -Credential $cred_jc -Filter 'OperatingSystem -like "*Server*"'  -properties  name,CanonicalName,OperatingSystem,operatingsystemversion,DNSHostName,lastLogOn,pwdlastset,
                whenCreated,OperatingSystemservicepack  | select name,CanonicalName,DNSHostName,OperatingSystem,operatingsystemversion,OperatingSystemservicepack,
				@{Name='lastlogon';Expression={[datetime]::FromFileTime($_."lastlogon")}},@{Name='pwdlastset';Expression={[datetime]::FromFileTime($_."pwdlastset")}},whencreated

            Trim($JCSRV)
			   }
   catch
    {
    $Sub = "Error in SRV Active Directory Discovery Script(DLESSCCM01)-JC"
    $errorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    emailit $sub $errormessage
    write-host $errormessage
    write-host $FailedItem
    }
	
	#AK
	$serviceacct_ak = "AK\smssqlsvc_ak"
    $api = "https://naps.itg.ti.com/winauthwebservices/api/v1"
    $endpoint_ak = "$api/secrets/225955/fields/password"
    $response_ak = Invoke-RestMethod $endpoint_ak -credential $cred -method Get
    
    if ($response_ak.Contains(" "))
    {
    Send-MailMessage -From "SCCM_AD_Disc_SRV@ti.com" -To "cmalert@list.ti.com" -Subject "Failed to get Password for $serviceacct_ak from PV. Script terminated" 
	-Body "End of message" -SmtpServer smtp.mail.ti.com
	Exit
    }

	$securePassword_ak = ConvertTo-SecureString $response_ak -AsPlainText -Force
	$cred_ak = New-Object System.Management.Automation.PSCredential -ArgumentList ($serviceacct_ak,$securePassword_ak)
 
    try{
    $AKSRV = Get-ADComputer -server "AK.EAD" -Credential $cred_ak -Filter 'OperatingSystem -like "*Server*"'  -properties  name,CanonicalName,OperatingSystem,operatingsystemversion,DNSHostName,lastLogOn,pwdlastset,
                whenCreated,OperatingSystemservicepack  | select name,CanonicalName,DNSHostName,OperatingSystem,operatingsystemversion,OperatingSystemservicepack,
				@{Name='lastlogon';Expression={[datetime]::FromFileTime($_."lastlogon")}},@{Name='pwdlastset';Expression={[datetime]::FromFileTime($_."pwdlastset")}},whencreated
            Trim($AKSRV)
			   }
   catch
    {
    $Sub = "Error in SRV Active Directory Discovery Script(DLESSCCM01)-AK"
    $errorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    emailit $sub $errormessage
    write-host $errormessage
    write-host $FailedItem
    }
	
	#AMK
	$serviceacct_amk = "DLPATT\smssqlsvc_dlpatt"
    $api = "https://naps.itg.ti.com/winauthwebservices/api/v1"
    $endpoint_amk = "$api/secrets/66952/fields/password"
    $response_amk = Invoke-RestMethod $endpoint_amk -credential $cred -method Get
    
    if ($response_amk.Contains(" "))
    {
    Send-MailMessage -From "SCCM_AD_Disc_SRV@ti.com" -To "cmalert@list.ti.com" -Subject "Failed to get Password for $serviceacct_amk from PV. Script terminated" 
	-Body "End of message" -SmtpServer smtp.mail.ti.com
	Exit
    }

	$securePassword_amk = ConvertTo-SecureString $response_amk -AsPlainText -Force
	$cred_amk = New-Object System.Management.Automation.PSCredential -ArgumentList ($serviceacct_amk,$securePassword_amk)
 
    try{
    $AMKSRV = Get-ADComputer -server "amkor.sc.ti.com.tw" -Credential $cred_amk -Filter 'OperatingSystem -like "*Server*"'  -properties  name,CanonicalName,OperatingSystem,operatingsystemversion,DNSHostName,lastLogOn,pwdlastset,
                whenCreated,OperatingSystemservicepack  | select name,CanonicalName,DNSHostName,OperatingSystem,operatingsystemversion,OperatingSystemservicepack,
				@{Name='lastlogon';Expression={[datetime]::FromFileTime($_."lastlogon")}},@{Name='pwdlastset';Expression={[datetime]::FromFileTime($_."pwdlastset")}},whencreated

            Trim($AMKSRV)
			   }
   catch
    {
    $Sub = "Error in SRV Active Directory Discovery Script(DLESSCCM01)-AMK"
    $errorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    emailit $sub $errormessage
    write-host $errormessage
    write-host $FailedItem
    }
  
	#DEV
	$serviceacct_dev = "DEV\smssqlsvc_dev"
    $api = "https://naps.itg.ti.com/winauthwebservices/api/v1"
    $endpoint_dev = "$api/secrets/66953/fields/password"
    $response_dev = Invoke-RestMethod $endpoint_dev -credential $cred -method Get
    
    if ($response_dev.Contains(" "))
    {
    Send-MailMessage -From "SCCM_AD_Disc_SRV@ti.com" -To "cmalert@list.ti.com" -Subject "Failed to get Password for $serviceacct_dev from PV. Script terminated" 
	-Body "End of message" -SmtpServer smtp.mail.ti.com
	Exit
    }

	$securePassword_dev = ConvertTo-SecureString $response_dev -AsPlainText -Force
	$cred_dev = New-Object System.Management.Automation.PSCredential -ArgumentList ($serviceacct_dev,$securePassword_dev)
 
    try{
    $DEVSRV = Get-ADComputer -server "dev.ti.ead" -Credential $cred_dev -Filter 'OperatingSystem -like "*Server*"'  -properties  name,CanonicalName,OperatingSystem,operatingsystemversion,DNSHostName,lastLogOn,pwdlastset,
                whenCreated,OperatingSystemservicepack  | select name,CanonicalName,DNSHostName,OperatingSystem,operatingsystemversion,OperatingSystemservicepack,
				@{Name='lastlogon';Expression={[datetime]::FromFileTime($_."lastlogon")}},@{Name='pwdlastset';Expression={[datetime]::FromFileTime($_."pwdlastset")}},whencreated

            Trim($DEVSRV)
			   }
   catch
    {
    $Sub = "Error in SRV Active Directory Discovery Script(DLESSCCM01)-DEV"
    $errorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    emailit $sub $errormessage
    write-host $errormessage
    write-host $FailedItem
	}
#$today = get-date -format "dd-MM-yyyy hh-mm-ss"
$Insertsql = $TISRV+$ENTSRV+$UTDSSRV+$PRESRV+$XENTSRV+$SEGSRV+$JCSRV+$AKSRV+$AMKSRV+$DEVSRV
#$insertsql | Export-Csv H:\Scripts\AD2SMS\Preethi-DEV\Server_Dump\All_$today.csv

#truncates the table
$sqlcmd1= "Truncate table SMS_AD_OU_DiscoverySRV"
Invoke-Sqlcmd -Database TIDB -Query $sqlcmd1 -ServerInstance DLESSCCM01
#Inserts the new data

foreach ($S in $Insertsql)
{

$cname=$s.name
$cou=$s.CanonicalName
$cDnsName=$s.DNSHostName
$cos=$s.OperatingSystem
$csp=$s.OperatingSystemservicepack
$clastlogon=$s.lastlogon
$lastpwd=$s.pwdlastset
$whencr=$s.whencreated
#$osbuild=$s.operatingsystemversion

# insert the data to Sql table
	$global:sqlcmd = "INSERT INTO SMS_AD_OU_DiscoverySRV (name0,OU,DNS,OS,SP,LastLogon,LastPwdSet,WhenCreated,Timestamp) VALUES ('$cname','$cou','$cDnsName','$cos','$csp','$clastlogon','$lastpwd','$whencr',getdate())"
	try
	{
	Invoke-Sqlcmd -Database TIDB -Query $sqlcmd -ServerInstance DLESSCCM01
	}
	catch
	{
	$errorMessage = $_.Exception.Message
	$FailedItem = $_.Exception.ItemName
	emailit $sub $errormessage
	write-host $errormessage
	write-host $FailedItem
	}

}
$db = Invoke-Sqlcmd -Database TIDB -Query "select count(name0) as Count from SMS_AD_OU_DiscoverySRV"  -ServerInstance DLESSCCM01
#$odb = Invoke-Sqlcmd -Database TIDB -Query "select count(name0) as Count from SMS_AD_OU_DiscoverySRV"  -ServerInstance DLESSCCM01
#$odbcount = $odb.Count
$dbcount = $db.Count
$adcount = $Insertsql.count
$body = [string]$adcount + "  Records in Active Directory. " + [string]$dbcount + "  Records on DLESSCCM01 Database. "# + "  Previous import: " + [string]$odbcount + " Records "
emailit $sub $body
