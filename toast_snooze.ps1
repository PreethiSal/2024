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



$Last_reboot = Get-ciminstance Win32_OperatingSystem | Select -Exp LastBootUpTime	
$Check_FastBoot = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -ea silentlycontinue).HiberbootEnabled 
If(($Check_FastBoot -eq $null) -or ($Check_FastBoot -eq 0))
	{
		$Boot_Event = Get-WinEvent -ProviderName 'Microsoft-Windows-Kernel-Boot'| where {$_.ID -eq 27 -and $_.message -like "*0x0*"}
		If($Boot_Event -ne $null)
			{
				$Last_boot = $Boot_Event[0].TimeCreated		
			}
	}
ElseIf($Check_FastBoot -eq 1) 	
	{
		$Boot_Event = Get-WinEvent -ProviderName 'Microsoft-Windows-Kernel-Boot'| where {$_.ID -eq 27 -and $_.message -like "*0x1*"}
		If($Boot_Event -ne $null)
			{
				$Last_boot = $Boot_Event[0].TimeCreated		
			}			
	}		
	
If($Last_boot -eq $null)
	{
		$Uptime = $Uptime = $Last_reboot
	}
Else
	{
		If($Last_reboot -gt $Last_boot)
			{
				$Uptime = $Last_reboot
			}
		Else
			{
				$Uptime = $Last_boot
			}	
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



<#$Current_Date = get-date
$Diff_boot_time = $Current_Date - $Uptime
$Boot_Uptime_Days = $Diff_boot_time.Days	#>	
#**************************************************************************************************************************
# 													TOAST NOTIF PART
#**************************************************************************************************************************
$Title = $Title 

$Scenario = 'reminder' 


$Action_Restart = "RestartScript:"
$Action_Snooze_5 = "Snooze_5:"
$Action_Snooze_10 = "Snooze_10:"

If(($Show_RestartNow_Button -eq $True))
	{
		$Actions = 
@"
  <actions>
        <action activationType="protocol" arguments="$Action_Restart" content="Restart now" />
         <action activationType="protocol" arguments="$Action_Snooze_5" content="Snooze 5 mins" />
        <action activationType="protocol" arguments="$Action_Snooze_10" content="Snooze 10 mins" />		
        <action activationType="protocol" arguments="Dismiss" content="Dismiss" />
   </actions>	
"@		
	}
Else
	{
		$Actions = 
@"
  <actions>
  <action activationType="protocol" arguments="$Action_Snooze_5" content="Snooze 5 mins" />
        <action activationType="protocol" arguments="$Action_Snooze_10" content="Snooze 10 mins" />
        <action activationType="protocol" arguments="Dismiss" content="Dismiss" />
   </actions>	
"@		
	}	


[xml]$Toast = @"
<toast scenario="$Scenario">
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

# Add Event for Button Actions
$ToastNotification.add_Activated({
    param($sender, $args)
    switch ($args.Arguments) {
        "Snooze_5:"  { Start-Sleep -Seconds 300; & $MyInvocation.MyCommand.Path }
        "Snooze_10:" { Start-Sleep -Seconds 600; & $MyInvocation.MyCommand.Path }
        "Dismiss"    { Write-Host "Dismissed" }
        "RestartScript:" { Write-Host "Restarting..." }
    }
})

# Display the Toast
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($AppID).Show($ToastXml)

if ($curexpol -eq "Restricted"){
$finexpol=Set-ExecutionPolicy Resrticted
write-host "Reverted executionpolicy is" $finexpol
}
else 
{write-host "Reverted executionpolicy is" $curexpol}
stop-transcript

# SIG # Begin signature block
# MIIkPgYJKoZIhvcNAQcCoIIkLzCCJCsCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAArYiiz/Kmu1+p
# b0b/vI2azGRo4Wxon3cokPxuTBPkbaCCHlkwggV+MIIEZqADAgECAhNcAAVmF+7B
# RWINgxNXAAEABWYXMA0GCSqGSIb3DQEBCwUAME4xCzAJBgNVBAYTAlVTMR4wHAYD
# VQQKExVUZXhhcyBJbnN0cnVtZW50cyBJbmMxHzAdBgNVBAMTFlRJIEFEIElzc3Vp
# bmcgQ0ExIC0gRzUwHhcNMjExMDA4MTY0MjQxWhcNMjYxMDA4MTY1MjQxWjB6MRow
# GAYDVQQKExFUZXhhcyBJbnN0cnVtZW50czEUMBIGA1UECxMLSVQgU2VydmljZXMx
# JjAkBgNVBAMTHVRJIEVsZWN0cm9uaWMgRGlzdHJpYnV0aW9uIHY1MR4wHAYJKoZI
# hvcNAQkBFg9lc2RAbGlzdC50aS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw
# ggEKAoIBAQCRbtXxXpQ/h8xghGcL5vsWT3uxDS3YS4AGXsNayCxQLOjbU/ICsduY
# MIlpFlizO6Rydqjx3ZvMX01R3Vi2/NIQKWNciAB3Afq/tmROWtFS3zFdX4QeGFRz
# s0SMCtzsQ4tZqFAIG9I1wOzJAdVoT2dGT10Hf4tGjWFn3petei+dhdKybwxjLf41
# gWn4QoMibRyRiUTHszgxfdls8XtkuXDptKI+L33ievDG8UZIGlMHZeHiaBgt5Fot
# 4j02shnTZRuosBdWjihC3r3GxdHulLmvFSa/xeZCg0dBkf+cB46UdPpH4vj51RL5
# Z6h7S+6d2mjaBzws/yDsuBkBik93Pg8NAgMBAAGjggInMIICIzA+BgkrBgEEAYI3
# FQcEMTAvBicrBgEEAYI3FQiHr4kuhJj1fIaBgRaLiSGhihCBdou0tOh6isW15H8C
# AWQCAQYwEwYDVR0lBAwwCgYIKwYBBQUHAwMwCwYDVR0PBAQDAgeAMBsGCSsGAQQB
# gjcVCgQOMAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFLf3ezX13e1+hfTEYwSE40su
# 1PivMB8GA1UdIwQYMBaAFGSCdJ1X4kPXg6X2CYXtcqMkuzP3MIGlBgNVHR8EgZ0w
# gZowgZeggZSggZGGRmh0dHA6Ly9jZXJ0ZGF0YS5leHQudGkuY29tL0NEUC9USSUy
# MEFEJTIwSXNzdWluZyUyMENBMSUyMC0lMjBHNSgxKS5jcmyGR2h0dHA6Ly9jZXJ0
# ZGF0YTIuZXh0LnRpLmNvbS9DRFAvVEklMjBBRCUyMElzc3VpbmclMjBDQTElMjAt
# JTIwRzUoMSkuY3JsMIG5BggrBgEFBQcBAQSBrDCBqTBSBggrBgEFBQcwAoZGaHR0
# cDovL2NlcnRkYXRhLmV4dC50aS5jb20vQUlBL1RJJTIwQUQlMjBJc3N1aW5nJTIw
# Q0ExJTIwLSUyMEc1KDEpLmNydDBTBggrBgEFBQcwAoZHaHR0cDovL2NlcnRkYXRh
# Mi5leHQudGkuY29tL0FJQS9USSUyMEFEJTIwSXNzdWluZyUyMENBMSUyMC0lMjBH
# NSgxKS5jcnQwDQYJKoZIhvcNAQELBQADggEBAFevOyxdq7VPSOG6NU3f8Zs/a0UX
# XEcpH2/vd3iHR+fVUIbXn9OBPY/TZx/zVqzRJvq2R+cqmXW4cb9M7Jt0k6eziRQJ
# Jg2+MRp4tGIOGmNAF3Fx5hzCY5+BU1U3dqkDnWAHHDJbyecIPmNko7GG1RO/nCH7
# eLwU3kFGYlF20hLroyP1j8jHy96YqpVrrOL25vL8znnLH5eMUJ5HvGvyxGtUMgEr
# 9vyjhRf/uq1rN7CLqUd75oK/0j5wjG0GLWBv/JBQqWHISVzd63mC1r0kpf/vE1PB
# +XdEe/G4hVkSugk6QeZ3dw2KIrNdh+OCKXcgzIPhr+XadAh+nB0hudE77eswggWN
# MIIEdaADAgECAhAOmxiO+dAt5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUAMGUxCzAJ
# BgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5k
# aWdpY2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBD
# QTAeFw0yMjA4MDEwMDAwMDBaFw0zMTExMDkyMzU5NTlaMGIxCzAJBgNVBAYTAlVT
# MRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5j
# b20xITAfBgNVBAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZI
# hvcNAQEBBQADggIPADCCAgoCggIBAL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK
# 2FnC4SmnPVirdprNrnsbhA3EMB/zG6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/G
# nhWlfr6fqVcWWVVyr2iTcMKyunWZanMylNEQRBAu34LzB4TmdDttceItDBvuINXJ
# IB1jKS3O7F5OyJP4IWGbNOsFxl7sWxq868nPzaw0QF+xembud8hIqGZXV59UWI4M
# K7dPpzDZVu7Ke13jrclPXuU15zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN
# 2NQ3pC4FfYj1gj4QkXCrVYJBMtfbBHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I
# 11pJpMLmqaBn3aQnvKFPObURWBf3JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KIS
# G2aadMreSx7nDmOu5tTvkpI6nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9
# HJXDj/chsrIRt7t/8tWMcCxBYKqxYxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4
# pncB4Q+UDCEdslQpJYls5Q5SUUd0viastkF13nqsX40/ybzTQRESW+UQUOsxxcpy
# FiIJ33xMdT9j7CFfxCBRa2+xq4aLT8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS31
# 2amyHeUbAgMBAAGjggE6MIIBNjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTs
# 1+OC0nFdZEzfLmc/57qYrhwPTzAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd
# 823IDzAOBgNVHQ8BAf8EBAMCAYYweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzAB
# hhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9j
# YWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQw
# RQYDVR0fBD4wPDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lD
# ZXJ0QXNzdXJlZElEUm9vdENBLmNybDARBgNVHSAECjAIMAYGBFUdIAAwDQYJKoZI
# hvcNAQEMBQADggEBAHCgv0NcVec4X6CjdBs9thbX979XB72arKGHLOyFXqkauyL4
# hxppVCLtpIh3bb0aFPQTSnovLbc47/T/gLn4offyct4kvFIDyE7QKt76LVbP+fT3
# rDB6mouyXtTP0UNEm0Mh65ZyoUi0mcudT6cGAxN3J0TU53/oWajwvy8LpunyNDzs
# 9wPHh6jSTEAZNUZqaVSwuKFWjuyk1T3osdz9HNj0d1pcVIxv76FQPfx2CWiEn2/K
# 2yCNNWAcAgPLILCsWKAOQGPFmCLBsln1VWvPJ6tsds5vIy30fnFqI2si/xK4VC0n
# ftg62fC2h5b9W9FcrBjDTZ9ztwGpn1eqXijiuZQwggXKMIIEsqADAgECAhMZAAAA
# CE3DVOq3SQ8TAAAAAAAIMA0GCSqGSIb3DQEBCwUAMEoxCzAJBgNVBAYTAlVTMR4w
# HAYDVQQKExVUZXhhcyBJbnN0cnVtZW50cyBJbmMxGzAZBgNVBAMTElRJIEFEIFJv
# b3QgQ0EgLSBHNTAeFw0yMTA2MTExNDMxMThaFw0zMTA2MTExNDQxMThaME4xCzAJ
# BgNVBAYTAlVTMR4wHAYDVQQKExVUZXhhcyBJbnN0cnVtZW50cyBJbmMxHzAdBgNV
# BAMTFlRJIEFEIElzc3VpbmcgQ0ExIC0gRzUwggEiMA0GCSqGSIb3DQEBAQUAA4IB
# DwAwggEKAoIBAQDGE1GEjtPu2yP64PXEzi8nzwkK1Sk1pu4BzL+6nfDGQKZJ9S++
# HFJl6rKNB9Fim3waj1+mUZWQCJg0XFpcb/CVzvgK/ARJDPDJEuoWSTUvqUa4cSwr
# 2NY4w8IJnFMZ2RybRx7sUVZonneooTpc4ZRdnSi6L5oIK+W+zzET4BExv5spYnfl
# mV+XW196Zn56v7x8+hdRlUa1JzENDZEQz2Am6/e1rH8y9otWYDCmz2QIjqWwY4Ko
# UtzOn2jqB/+p17nH2+fiGBg8740QhRHwAJAtpmd0wdAqw2ommAd9UCUsSOjLcWZt
# Rylk4eoR2KcS5uO5WACaOvurHjXyDoxPm9qNAgMBAAGjggKjMIICnzASBgkrBgEE
# AYI3FQEEBQIDAQABMCMGCSsGAQQBgjcVAgQWBBQYCkzGbO9TyZrDp4iJu4axRxkA
# NDAdBgNVHQ4EFgQUZIJ0nVfiQ9eDpfYJhe1yoyS7M/cwgZ8GA1UdIASBlzCBlDCB
# kQYLYIZIAYb8DgEHAQEwgYEwSgYIKwYBBQUHAgIwPh48AEMAZQByAHQAaQBmAGkA
# YwBhAHQAZQAgAFAAcgBhAGMAdABpAGMAZQAgAFMAdABhAHQAZQBtAGUAbgB0MDMG
# CCsGAQUFBwIBFidodHRwOi8vY2VydGRhdGEuZXh0LnRpLmNvbS9DUFMvY3BzLmh0
# bQAwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEwCwYDVR0PBAQDAgGGMBIGA1Ud
# EwEB/wQIMAYBAf8CAQEwHwYDVR0jBBgwFoAUsvjf3bGB5u1h18bvuPdvrLJKOvkw
# gZcGA1UdHwSBjzCBjDCBiaCBhqCBg4Y/aHR0cDovL2NlcnRkYXRhLmV4dC50aS5j
# b20vQ0RQL1RJJTIwQUQlMjBSb290JTIwQ0ElMjAtJTIwRzUuY3JshkBodHRwOi8v
# Y2VydGRhdGEyLmV4dC50aS5jb20vQ0RQL1RJJTIwQUQlMjBSb290JTIwQ0ElMjAt
# JTIwRzUuY3JsMIGrBggrBgEFBQcBAQSBnjCBmzBLBggrBgEFBQcwAoY/aHR0cDov
# L2NlcnRkYXRhLmV4dC50aS5jb20vQUlBL1RJJTIwQUQlMjBSb290JTIwQ0ElMjAt
# JTIwRzUuY3J0MEwGCCsGAQUFBzAChkBodHRwOi8vY2VydGRhdGEyLmV4dC50aS5j
# b20vQUlBL1RJJTIwQUQlMjBSb290JTIwQ0ElMjAtJTIwRzUuY3J0MA0GCSqGSIb3
# DQEBCwUAA4IBAQBIKFbMUOIhU6p8H30tMUDmXitI5L/5Zc2SQcvdCVz/WHTdn1ti
# RqnrAOJrXtADxcQjH0EYRGGE+kaEHrNgXXWOdGgwoK9iHNjEaUUXbU4tr0YtKjN+
# iIr+zlqcsWjG1rtnxfSlBB+aaUcB26i1qLjQbkLuldB2GcMleYN/9Hj97cmalmBk
# 4T2IhfQw0ap1TcIaT222pe5U/gOvjEvk9kCzI8l6oyGMStTD5ZXXJQhc9T7sST4P
# Hod7SjkGIiR5CherYApGwJSyJ7jkBeEFdi1WcDklUWng/1XLIYv85BLxEIkD/REX
# 2nIwDm+49+fKM5ezMJ6602Hm2rilbyE7vFxKMIIGrjCCBJagAwIBAgIQBzY3tyRU
# fNhHrP0oZipeWzANBgkqhkiG9w0BAQsFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UE
# ChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYD
# VQQDExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQwHhcNMjIwMzIzMDAwMDAwWhcN
# MzcwMzIyMjM1OTU5WjBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQs
# IEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEy
# NTYgVGltZVN0YW1waW5nIENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKC
# AgEAxoY1BkmzwT1ySVFVxyUDxPKRN6mXUaHW0oPRnkyibaCwzIP5WvYRoUQVQl+k
# iPNo+n3znIkLf50fng8zH1ATCyZzlm34V6gCff1DtITaEfFzsbPuK4CEiiIY3+va
# PcQXf6sZKz5C3GeO6lE98NZW1OcoLevTsbV15x8GZY2UKdPZ7Gnf2ZCHRgB720RB
# idx8ald68Dd5n12sy+iEZLRS8nZH92GDGd1ftFQLIWhuNyG7QKxfst5Kfc71ORJn
# 7w6lY2zkpsUdzTYNXNXmG6jBZHRAp8ByxbpOH7G1WE15/tePc5OsLDnipUjW8LAx
# E6lXKZYnLvWHpo9OdhVVJnCYJn+gGkcgQ+NDY4B7dW4nJZCYOjgRs/b2nuY7W+yB
# 3iIU2YIqx5K/oN7jPqJz+ucfWmyU8lKVEStYdEAoq3NDzt9KoRxrOMUp88qqlnNC
# aJ+2RrOdOqPVA+C/8KI8ykLcGEh/FDTP0kyr75s9/g64ZCr6dSgkQe1CvwWcZklS
# UPRR8zZJTYsg0ixXNXkrqPNFYLwjjVj33GHek/45wPmyMKVM1+mYSlg+0wOI/rOP
# 015LdhJRk8mMDDtbiiKowSYI+RQQEgN9XyO7ZONj4KbhPvbCdLI/Hgl27KtdRnXi
# YKNYCQEoAA6EVO7O6V3IXjASvUaetdN2udIOa5kM0jO0zbECAwEAAaOCAV0wggFZ
# MBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0OBBYEFLoW2W1NhS9zKXaaL3WMaiCP
# nshvMB8GA1UdIwQYMBaAFOzX44LScV1kTN8uZz/nupiuHA9PMA4GA1UdDwEB/wQE
# AwIBhjATBgNVHSUEDDAKBggrBgEFBQcDCDB3BggrBgEFBQcBAQRrMGkwJAYIKwYB
# BQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0
# cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5j
# cnQwQwYDVR0fBDwwOjA4oDagNIYyaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0Rp
# Z2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJ
# YIZIAYb9bAcBMA0GCSqGSIb3DQEBCwUAA4ICAQB9WY7Ak7ZvmKlEIgF+ZtbYIULh
# sBguEE0TzzBTzr8Y+8dQXeJLKftwig2qKWn8acHPHQfpPmDI2AvlXFvXbYf6hCAl
# NDFnzbYSlm/EUExiHQwIgqgWvalWzxVzjQEiJc6VaT9Hd/tydBTX/6tPiix6q4XN
# Q1/tYLaqT5Fmniye4Iqs5f2MvGQmh2ySvZ180HAKfO+ovHVPulr3qRCyXen/KFSJ
# 8NWKcXZl2szwcqMj+sAngkSumScbqyQeJsG33irr9p6xeZmBo1aGqwpFyd/EjaDn
# mPv7pp1yr8THwcFqcdnGE4AJxLafzYeHJLtPo0m5d2aR8XKc6UsCUqc3fpNTrDsd
# CEkPlM05et3/JWOZJyw9P2un8WbDQc1PtkCbISFA0LcTJM3cHXg65J6t5TRxktcm
# a+Q4c6umAU+9Pzt4rUyt+8SVe+0KXzM5h0F4ejjpnOHdI/0dKNPH+ejxmF/7K9h+
# 8kaddSweJywm228Vex4Ziza4k9Tm8heZWcpw8De/mADfIBZPJ/tgZxahZrrdVcA6
# KYawmKAr7ZVBtzrVFZgxtGIJDwq9gdkT/r+k0fNX2bwE+oLeMt8EifAAzV3C+dAj
# fwAL5HYCJtnwZXZCpimHCUcr5n8apIUP/JiW9lVUKx+A+sDyDivl1vupL0QVSucT
# Dh3bNzgaoSv27dZ8/DCCBsIwggSqoAMCAQICEAVEr/OUnQg5pr/bP1/lYRYwDQYJ
# KoZIhvcNAQELBQAwYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJ
# bmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2
# IFRpbWVTdGFtcGluZyBDQTAeFw0yMzA3MTQwMDAwMDBaFw0zNDEwMTMyMzU5NTla
# MEgxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjEgMB4GA1UE
# AxMXRGlnaUNlcnQgVGltZXN0YW1wIDIwMjMwggIiMA0GCSqGSIb3DQEBAQUAA4IC
# DwAwggIKAoICAQCjU0WHHYOOW6w+VLMj4M+f1+XS512hDgncL0ijl3o7Kpxn3GIV
# WMGpkxGnzaqyat0QKYoeYmNp01icNXG/OpfrlFCPHCDqx5o7L5Zm42nnaf5bw9Yr
# IBzBl5S0pVCB8s/LB6YwaMqDQtr8fwkklKSCGtpqutg7yl3eGRiF+0XqDWFsnf5x
# XsQGmjzwxS55DxtmUuPI1j5f2kPThPXQx/ZILV5FdZZ1/t0QoRuDwbjmUpW1R9d4
# KTlr4HhZl+NEK0rVlc7vCBfqgmRN/yPjyobutKQhZHDr1eWg2mOzLukF7qr2JPUd
# vJscsrdf3/Dudn0xmWVHVZ1KJC+sK5e+n+T9e3M+Mu5SNPvUu+vUoCw0m+PebmQZ
# BzcBkQ8ctVHNqkxmg4hoYru8QRt4GW3k2Q/gWEH72LEs4VGvtK0VBhTqYggT02ke
# fGRNnQ/fztFejKqrUBXJs8q818Q7aESjpTtC/XN97t0K/3k0EH6mXApYTAA+hWl1
# x4Nk1nXNjxJ2VqUk+tfEayG66B80mC866msBsPf7Kobse1I4qZgJoXGybHGvPrhv
# ltXhEBP+YUcKjP7wtsfVx95sJPC/QoLKoHE9nJKTBLRpcCcNT7e1NtHJXwikcKPs
# CvERLmTgyyIryvEoEyFJUX4GZtM7vvrrkTjYUQfKlLfiUKHzOtOKg8tAewIDAQAB
# o4IBizCCAYcwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/
# BAwwCgYIKwYBBQUHAwgwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcB
# MB8GA1UdIwQYMBaAFLoW2W1NhS9zKXaaL3WMaiCPnshvMB0GA1UdDgQWBBSltu8T
# 5+/N0GSh1VapZTGj3tXjSTBaBgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsMy5k
# aWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRSU0E0MDk2U0hBMjU2VGltZVN0
# YW1waW5nQ0EuY3JsMIGQBggrBgEFBQcBAQSBgzCBgDAkBggrBgEFBQcwAYYYaHR0
# cDovL29jc3AuZGlnaWNlcnQuY29tMFgGCCsGAQUFBzAChkxodHRwOi8vY2FjZXJ0
# cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRSU0E0MDk2U0hBMjU2VGlt
# ZVN0YW1waW5nQ0EuY3J0MA0GCSqGSIb3DQEBCwUAA4ICAQCBGtbeoKm1mBe8cI1P
# ijxonNgl/8ss5M3qXSKS7IwiAqm4z4Co2efjxe0mgopxLxjdTrbebNfhYJwr7e09
# SI64a7p8Xb3CYTdoSXej65CqEtcnhfOOHpLawkA4n13IoC4leCWdKgV6hCmYtld5
# j9smViuw86e9NwzYmHZPVrlSwradOKmB521BXIxp0bkrxMZ7z5z6eOKTGnaiaXXT
# UOREEr4gDZ6pRND45Ul3CFohxbTPmJUaVLq5vMFpGbrPFvKDNzRusEEm3d5al08z
# jdSNd311RaGlWCZqA0Xe2VC1UIyvVr1MxeFGxSjTredDAHDezJieGYkD6tSRN+9N
# UvPJYCHEVkft2hFLjDLDiOZY4rbbPvlfsELWj+MXkdGqwFXjhr+sJyxB0JozSqg2
# 1Llyln6XeThIX8rC3D0y33XWNmdaifj2p8flTzU8AL2+nCpseQHc2kTmOt44Owde
# OVj0fHMxVaCAEcsUDH6uvP6k63llqmjWIso765qCNVcoFstp8jKastLYOrixRoZr
# uhf9xHdsFWyuq69zOuhJRrfVf8y2OMDY7Bz1tqG4QyzfTkx9HmhwwHcK1ALgXGC7
# KP845VJa1qwXIiNO9OzTF/tQa/8Hdx9xl0RBybhG02wyfFgvZ0dl5Rtztpn5aywG
# Ru9BHvDwX+Db2a2QgESvgBBBijGCBTswggU3AgEBMGUwTjELMAkGA1UEBhMCVVMx
# HjAcBgNVBAoTFVRleGFzIEluc3RydW1lbnRzIEluYzEfMB0GA1UEAxMWVEkgQUQg
# SXNzdWluZyBDQTEgLSBHNQITXAAFZhfuwUViDYMTVwABAAVmFzANBglghkgBZQME
# AgEFAKCBhDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEM
# BgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMC8GCSqG
# SIb3DQEJBDEiBCDTfKPCF84C5FbdQ+I4WR8P5k877TTp1yVolhzYJdymqzANBgkq
# hkiG9w0BAQEFAASCAQBonOOfucEy8/3IrpENiSAziZAW97y/F1eHt5R4hU0wsMMZ
# k+uWTPd1RL9BaZfR9PQ4tO+DFaOcOgoI2GH4b3a5NBeq0/tEjY8/3JdKw7m1Dx7H
# TgA8M9epW7JFxZHjlF19CIR+1MG/uSiUf7jI59vDyfhYMwbgv6y5N5Sg5I/4KVm0
# aKukJfgcxQXfPxkVVBidfZG4Yuk9jgBD7oytGZwWNzw2+VBHIhDIGS1MX3BpALvP
# 8t9Aq3H/xGpBz/lqRTqDjOMNfVCU6/nwSY6639Ps/QG7QajRSoUyjHAFyHWW67zq
# FTteVg5Qyr7nzX/bpVHG0WxjWSF8EJvc8YZhr+QroYIDIDCCAxwGCSqGSIb3DQEJ
# BjGCAw0wggMJAgEBMHcwYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0
# LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hB
# MjU2IFRpbWVTdGFtcGluZyBDQQIQBUSv85SdCDmmv9s/X+VhFjANBglghkgBZQME
# AgEFAKBpMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8X
# DTI0MDMyNzA5NTE1NlowLwYJKoZIhvcNAQkEMSIEIGo9zLqddBpxTaqQ2kPlNL4f
# Z8RBvC2U+AM9upcEBf8FMA0GCSqGSIb3DQEBAQUABIICAFNIZK/YiH0oPlcvZH11
# 4s9k392BXiH+R/9tzpoke71hqSRZaRvHUADFiwlvADzAlhleR1tEulRbh45fTQdx
# P1GIORH8fO/1Ht4nl9f5DKjQfwUutwr2fu6wNNHniLkr/YpTK8IBEYrpqxUzXhCm
# H/iDd/CpwOoLn73FWP5VLIqjENUessjGuox6RiL7RcnJzSL37j4/uh1mYf4LblED
# 4EKqu4QQFXZUxxZKjMzMoxhi1SPC/tOBivmy5F+/bjewiwRFmgkzR3fncNdNX/BJ
# eDrc3Mhcm2bbS8LEvJZA62x+p/f1Q2Cq1UGjo4aokUdGaw1fOS9WpXKwv6fjvExB
# bhJlM0Dfa2Dd+tYCQ+/Q0PWNfl9OE2eqH9Sy+AuTBMxD5hK9NARU4NTmnowUhniT
# kYNvwT3f+DgbBnxjXZiLA843LOuhHOmp4h5KoNlWI+WyIOFAcER9h2IWKQsXWi2K
# XUM5zOURYAHFSbVZttTmcpFhTOoomQvOtldZkLftzjUYi09QQv4ytP9hixlK29Dw
# 4yHpp4RJxqXq4PBPwew5Rhelv7bWP72KnA6Z2LrXNM50n5OzS5SIZgT0ltPE5A3l
# iBb9cKP3gR9FLyQZTp7P8rnVHjaUPRHooj3kFnaSfQp/D3LHOMA9eRQJRPW1cYVy
# bN3dQQvdkL6lgb0ogwfya8uy
# SIG # End signature block
