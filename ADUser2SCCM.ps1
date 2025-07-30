#Please refer to the readme.txt file at F:\SCCM_Schedules\AD2SMS\readme.txt for more details on naps pw access process.

#function for sending error details by email
function emailit($subx,$bodyx)
    {
    send-mailmessage -to cmalert@list.ti.com -from SCCM_AD_User_Disc@ti.com -smtpserver smtp.mail.ti.com -body $bodyx -subject $subx
    }
$sub = "Active Directory to SCCM - Userdata Import Summary DLESSCCM01"

#Querying AD for userdata
try{
$ss=Get-ADUser -Filter 'Enabled -eq "True"' -Properties SamAccountName,givenName,sn,tiPerOrganizationTitle,extensionAttribute4,EmailAddress,MobilePhone,OfficePhone,ipPhone,
tiPerBuildingCode,tiPerSiteName,l,tiPerOrg,pwdlastset|select SamAccountName,givenName,sn,tiPerOrganizationTitle,extensionAttribute4,EmailAddress,MobilePhone,OfficePhone,ipPhone,
tiPerBuildingCode,tiPerSiteName,l,tiPerOrg,@{Name='pwdlastset';Expression={[datetime]::FromFileTime($_."pwdlastset")}}
}
catch{
	$errorMessage = $_.Exception.Message
		$FailedItem = $_.Exception.ItemName
		emailit $sub $errormessage
		write-host $errormessage
		write-host $FailedItem
	}

#truncating Table
$sqlcmd1="truncate table ADUserData"

#inserting new data
Invoke-Sqlcmd -Database TIDB -Query $sqlcmd1 -ServerInstance DLESSCCM01


foreach ($s in $ss)
{

$UserID=$s.SamAccountName
$GivenName=$s.givenName
$LastName=$s.sn
$Division=$s.tiPerOrganizationTitle
$Cost_Center=$s.extensionAttribute4
$Email=$s.EmailAddress
$Mobile=$s.MobilePhone
$Phone=$s.OfficePhone
$ipPhone=$s.ipPhone
$Building=$s.tiPerBuildingCode
$Site=$s.tiPerSiteName
$Location=$s.l
$SBE=$s.tiperorg
$pwdage=$s.pwdlastset


$global:sqlcmd = "INSERT INTO ADUserData (UserID,GivenName,LastName,Division,Cost_Center,Email,Mobile,Phone,ipPhone,Building,Site,Location,SBE,PasswordAge) VALUES 
('$UserID','$($GivenName -replace "'",""")','$LastName','$($Division -replace "'",""")','$Cost_Center','$($Email -replace "'",""")','$Mobile','$Phone','$ipPhone','$($Building -replace "'",""")',
'$Site','$($Location -replace "'",""")','$SBE','$pwdage')"
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
$db = Invoke-Sqlcmd -Database TIDB -Query "select count(UserID) as Count from ADUserData"  -ServerInstance DLESSCCM01
$dbcount = $db.Count
$adcount = $ss.count
$body = [string]$adcount + "  Records in AD.    " + [string]$dbcount + "  Records on DLESSCCM01 Database."
#" + "  Previous import: " + [string]$odbcount + " Records "
emailit $sub $body
