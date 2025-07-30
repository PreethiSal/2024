# ***************************************************************************
# 								Part to fill
# ***************************************************************************
# Choose header picture
# By default the picture is the GIF, it will use the GIF provided from my github here below

#Log path
$logpath = "C:\ProgramData\TILogs\HW"
$logname = "toast.log"   
If (Test-Path $logpath) {
    Start-Transcript -Path $logpath\$logname -append
    Write-Output $logpath" exists. Skipping creating new dir." 
}
Else {
    New-Item -Path $logpath -ItemType Directory | Out-Null
    Start-Transcript -Path $logpath\$logname -force
    Write-Output "The folder $logpath doesn't exist. Creating now." 
}


#Get the execution policy 
$curexpol= get-executionpolicy
write-host "Current Execution Policy is" $curexpol
if ($curexpol -eq "Restricted"){
$setexpol=Set-ExecutionPolicy Unresrticted
write-host "Set Execution Policy is" $setexpol
}


# Set toast text
# Use the $Title variable to change the title of the toast
$Title = "`nSent on behalf of TI SCCM Team"

# Use the $Message variable to change the warning message
$Message = "`nWe have updated your Laptop's hardware drivers. Please initiate the reboot in order to complete the installation.This may include system BIOS update, please keep your machine connected to the power supply until the installation is complete."
# Use the $Advice variable to change the advice message
$Advice = "`nHardware Drivers Update"
# Use the $Text_AppName variable to set your company name
$Text_AppName = "TI System Administrator informs you"

# Here belo you can choose to display or not a second button
# This button allows the use to reboot the device
# For this, set the $Show_RestartNow_Button variable to $True or $False
$Show_RestartNow_Button = $True # It will add a button to reboot the device
# ***************************************************************************
# 								Part to fill
# ***************************************************************************




# ***************************************************************************
# 								Export picture
# ***************************************************************************
#If($Header_type -eq "GIF")
	<#{
		$HeroImage = "C:\Users\A0497099\Desktop\Toast\Images\ToastHeroImageOS.jpg"		
		invoke-webrequest -Uri $URL -OutFile $HeroImage -usebasicparsing
	}#>

#Get the execution policy 
$curexpol= get-executionpolicy
if ($curexpol -eq "Restricted"){
Set-ExecutionPolicy unresrticted
}

#Current Directory
$ScriptPath = $MyInvocation.MyCommand.Path
$CurrentDir = Split-Path $ScriptPath


		#Images
    $BadgeImage = "file:///$CurrentDir/ti.jpg"
    $HeroImage = "file:///$CurrentDir/ToastHeroImageOS.jpg"
		#[byte[]]$Bytes = [convert]::FromBase64String($Picture_Base64)
		#[System.IO.File]::WriteAllBytes($HeroImage,$Bytes)			
	
	

Function Set_Action
	{
		param(
		$Action_Name		
		)	
		
		$Main_Reg_Path = "HKCU:\SOFTWARE\Classes\$Action_Name"
		$Command_Path = "$Main_Reg_Path\shell\open\command"
		$CMD_Script = "C:\Windows\Temp\$Action_Name.cmd"
		New-Item $Command_Path -Force
		New-ItemProperty -Path $Main_Reg_Path -Name "URL Protocol" -Value "" -PropertyType String -Force | Out-Null
		Set-ItemProperty -Path $Main_Reg_Path -Name "(Default)" -Value "URL:$Action_Name Protocol" -Force | Out-Null
		Set-ItemProperty -Path $Command_Path -Name "(Default)" -Value $CMD_Script -Force | Out-Null		
	}

$Restart_Script = @'
shutdown /r /f /t 120
'@

$Script_Export_Path = "C:\Windows\Temp"
If($Show_RestartNow_Button -eq $True)
	{
		$Restart_Script | out-file "$Script_Export_Path\RestartScript.cmd" -Force -Encoding ASCII
		Set_Action -Action_Name RestartScript	
	}

Function Register-NotificationApp($AppID,$AppDisplayName) {
    [int]$ShowInSettings = 0

    [int]$IconBackgroundColor = 0
	$IconUri = "C:\Windows\ImmersiveControlPanel\images\logo.png"
	
    $AppRegPath = "HKCU:\Software\Classes\AppUserModelId"
    $RegPath = "$AppRegPath\$AppID"
	
	$Notifications_Reg = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings'
	If(!(Test-Path -Path "$Notifications_Reg\$AppID")) 
		{
			New-Item -Path "$Notifications_Reg\$AppID" -Force
			New-ItemProperty -Path "$Notifications_Reg\$AppID" -Name 'ShowInActionCenter' -Value 1 -PropertyType 'DWORD' -Force
		}

	If((Get-ItemProperty -Path "$Notifications_Reg\$AppID" -Name 'ShowInActionCenter' -ErrorAction SilentlyContinue).ShowInActionCenter -ne '1') 
		{
			New-ItemProperty -Path "$Notifications_Reg\$AppID" -Name 'ShowInActionCenter' -Value 1 -PropertyType 'DWORD' -Force
		}	
		
    try {
        if (-NOT(Test-Path $RegPath)) {
            New-Item -Path $AppRegPath -Name $AppID -Force | Out-Null
        }
        $DisplayName = Get-ItemProperty -Path $RegPath -Name DisplayName -ErrorAction SilentlyContinue | Select -ExpandProperty DisplayName -ErrorAction SilentlyContinue
        if ($DisplayName -ne $AppDisplayName) {
            New-ItemProperty -Path $RegPath -Name DisplayName -Value $AppDisplayName -PropertyType String -Force | Out-Null
        }
        $ShowInSettingsValue = Get-ItemProperty -Path $RegPath -Name ShowInSettings -ErrorAction SilentlyContinue | Select -ExpandProperty ShowInSettings -ErrorAction SilentlyContinue
        if ($ShowInSettingsValue -ne $ShowInSettings) {
            New-ItemProperty -Path $RegPath -Name ShowInSettings -Value $ShowInSettings -PropertyType DWORD -Force | Out-Null
        }
		
		New-ItemProperty -Path $RegPath -Name IconUri -Value $IconUri -PropertyType ExpandString -Force | Out-Null	
		New-ItemProperty -Path $RegPath -Name IconBackgroundColor -Value $IconBackgroundColor -PropertyType ExpandString -Force | Out-Null		
		
    }
    catch {}
}



#Run the toast of the script is running in the context of the Logged On User
    If (!(([System.Security.Principal.WindowsIdentity]::GetCurrent()).Name -eq "NT AUTHORITY\SYSTEM")) {

        $Log = (Join-Path $ENV:Windir "Temp\$($ToastGuid).log")
        Start-Transcript $Log

        #Get logged on user DisplayName
        #Try to get the DisplayName for Domain User
        $ErrorActionPreference = "Continue"

        Try {
            Write-Output "Trying Identity LogonUI Registry Key for Domain User info..."
            Get-Itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI" -Name "LastLoggedOnDisplayName" -ErrorAction Stop
            $User = Get-Itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI" -Name "LastLoggedOnDisplayName" | Select-Object -ExpandProperty LastLoggedOnDisplayName -ErrorAction Stop
        
            If ($Null -eq $User) {  
                $Firstname = $Null
            } 
            else {
                $DisplayName = $User.Split(" ")
                $Firstname = $DisplayName[0]
            }
        }
        Catch [System.Management.Automation.PSArgumentException] {
            "Registry Key Property missing" 
            Write-Warning "Registry Key for LastLoggedOnDisplayName could not be found."
            $Firstname = $Null
        }
        Catch [System.Management.Automation.ItemNotFoundException] {
            "Registry Key itself is missing" 
            Write-Warning "Registry value for LastLoggedOnDisplayName could not be found."
            $Firstname = $Null
        }

        #Try to get the DisplayName for Azure AD User
        If ($Null -eq $Firstname) {
            Write-Output "Trying Identity Store Cache for Azure AD User info..."
            Try {
                $UserSID = (whoami /user /fo csv | ConvertFrom-Csv).Sid
                $LogonCacheSID = (Get-ChildItem HKLM:\SOFTWARE\Microsoft\IdentityStore\LogonCache -Recurse -Depth 2 | Where-Object { $_.Name -match $UserSID }).Name
                If ($LogonCacheSID) { 
                    $LogonCacheSID = $LogonCacheSID.Replace("HKEY_LOCAL_MACHINE", "HKLM:") 
                    $User = Get-ItemProperty -Path $LogonCacheSID | Select-Object -ExpandProperty DisplayName -ErrorAction Stop
                    $DisplayName = $User.Split(" ")
                    $Firstname = $DisplayName[0]
                }
               # }
                else {
                    Write-Warning "Could not get DisplayName property from Identity Store Cache for Azure AD User"
                    $Firstname = $Null
                }
            }
            Catch [System.Management.Automation.PSArgumentException] {
                Write-Warning "Could not get DisplayName property from Identity Store Cache for Azure AD User"
                Write-Output "Resorting to whoami info for Toast DisplayName..."
                $Firstname = $Null
            }
            Catch [System.Management.Automation.ItemNotFoundException] {
                Write-Warning "Could not get SID from Identity Store Cache for Azure AD User"
                Write-Output "Resorting to whoami info for Toast DisplayName..."
                $Firstname = $Null
            }
            Catch {
                Write-Warning "Could not get SID from Identity Store Cache for Azure AD User"
                Write-Output "Resorting to whoami info for Toast DisplayName..."
                $Firstname = $Null  
            }
        }

        #Try to get the DisplayName from whoami
        If ($Null -eq $Firstname) {
            Try {
                Write-Output "Trying Identity whoami.exe for DisplayName info..."
                $User = whoami.exe
                $Firstname = (Get-Culture).textinfo.totitlecase($User.Split("\")[1])
                Write-Output "DisplayName retrieved from whoami.exe"
            }
            Catch {
                Write-Warning "Could not get DisplayName from whoami.exe"
            }
        }

        #If DisplayName could not be obtained, leave it blank
        If ($Null -eq $Firstname) {
            Write-Output "DisplayName could not be obtained, it will be blank in the Toast"
        }
                   
        #Get Hour of Day and set Custom Hello
        $Hour = (Get-Date).Hour
        If ($Hour -lt 12) { $CustomHello = "Good Morning $($Firstname)" }
        ElseIf ($Hour -gt 16) { $CustomHello = "Good Evening $($Firstname)" }
        Else { $CustomHello = "Good Afternoon $($Firstname)" }

}


	
#**************************************************************************************************************************
# 													TOAST NOTIF PART
#**************************************************************************************************************************
$Title = $Title 

$Scenario = 'reminder' 


$Action_Restart = "RestartScript:"
If(($Show_RestartNow_Button -eq $True))
	{
		$Actions = 
@"
  <actions>
        <action activationType="protocol" arguments="$Action_Restart" content="Restart now" />		
        <action activationType="protocol" arguments="Dismiss" content="Dismiss" />
   </actions>	
"@		
	}
Else
	{
		$Actions = 
@"
  <actions>
        <action activationType="protocol" arguments="Dismiss" content="Dismiss" />
   </actions>	
"@		
	}	


[xml]$Toast = @"
<toast scenario="$Scenario" duration="long">
    <visual>
    <binding template="ToastGeneric">
    <text>$CustomHello</text>
        <image placement="hero" src="$HeroImage"/>
        <text placement="attribution">$Attribution</text>
        <image placement="appLogoOverride" hint-crop="circle" src="$BadgeImage"/>
        <text>$Title</text>
        <group>
            <subgroup>     
                <text hint-style="body" hint-wrap="true" >$Advice</text>
            </subgroup>
        </group>
		
		<group>				
			<subgroup>     
				<text hint-style="body" hint-wrap="true" >$Message</text>								
			</subgroup>				
		</group>				
    </binding>
    </visual>
	$Actions
</toast>
"@	


$AppID = $Text_AppName
$AppDisplayName = $Text_AppName
Register-NotificationApp -AppID $Text_AppName -AppDisplayName $Text_AppName

# Toast creation and display
$Load = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
$Load = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]
$ToastXml = New-Object -TypeName Windows.Data.Xml.Dom.XmlDocument
$ToastXml.LoadXml($Toast.OuterXml)	
# Display the Toast
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($AppID).Show($ToastXml)

if ($curexpol -eq "Restricted"){
$finexpol=Set-ExecutionPolicy Resrticted
write-host "Reverted executionpolicy is" $finexpol
}
else 
{write-host "Reverted executionpolicy is" $curexpol}
stop-transcript

