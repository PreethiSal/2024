#Log path
$logpath = "C:\ProgramData\TILogs\HW"
$logname = "HW_script.log"   
If (Test-Path $logpath) {
    Start-Transcript -Path $logpath\$logname -force
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
$setexpol=Set-ExecutionPolicy Unresrticted -Scope CurrentUser
write-host "Set Execution Policy is" $setexpol
}


<#Checking if there is a active user session
Function Active-session{
$status=query user /server:$SERVER 
$state = ($status | Select-String -Pattern "Active").ToString()
return $state
}#>

#Current Directory
$ScriptPath = $MyInvocation.MyCommand.Path
$CurrentDir = Split-Path $ScriptPath

#HP and Dell log path 
$log_dell="C:\temp\DCU_reports.log"
$log_hp="C:\TEMP\HPIA_Reports\HP Image Assistant.log"

#Function to get path: Dell
Function findpath-Dell
{
$filepath=Get-Childitem –Path  "C:\*\dell\CommandUpdate\" -Recurse |where {$_.name -match "dcu-cli.exe" } | Select Fullname,@{n="ProductVersion";e={$_.versioninfo.productversion}} |sort-object -Property "ProductVersion" -Descending
$path=$filepath[0].FullName
if ([System.IO.File]::Exists($path)){
return $path
}
else{write-host "Dell Command Update is not installed.."}
}


#Function to get path: HP
Function findpath-HP
{
$filepath=Get-Childitem –Path  "C:\swsetup\" -Recurse |where {$_.name -match "hpimageassistant.exe" } | Select Fullname,@{n="ProductVersion";e={$_.versioninfo.productversion}} |sort-object -Property "ProductVersion" -Descending
$path=$filepath[0].FullName
if ([System.IO.File]::Exists($path)){
return $path
}
else{write-host "HP Image Assistant is not installed.."}
}

function Dell_notfiy{
try{

 if([System.IO.File]::Exists($log_dell))
 {
  $content_dell= get-content -path $log_dell
  if($content_dell -match "return code: 1" ){

  write-host "Needs Reboot"
 
 
 $toastpath=Join-Path $logpath "Toast_update.ps1"
   $QuotedScriptPath = "`"$toastpath`""
  $command = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -WindowStyle Hidden -file $QuotedScriptPath"
  Start-Process -FilePath "powershell" -WorkingDirectory $currentdir -argumentlist $command -wait -RedirectStandardOutput "C:\temp\toastlog.log"
    
  
  }
  }}
  catch{Write-Warning $_.Exception.Message}
 }
 


 function HP_notfiy{

 try{

 if([System.IO.File]::Exists($log_hp))
 {
  $content_hp= get-content -path $log_hp
  if($content_hp -match "exit code: 3010" ){
  write-host "Needs Reboot"
 
 $toastpath=Join-Path $logpath "Toast_update.ps1"
   $QuotedScriptPath = "`"$toastpath`""
  $command = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -WindowStyle Hidden -file $QuotedScriptPath"
  Start-Process -FilePath "powershell" -WorkingDirectory $currentdir -argumentlist $command -wait -RedirectStandardOutput "C:\temp\toastlog.log"
    
  }
  }}
  catch{Write-Warning $_.Exception.Message}
 }


 Function RegistrySettingsSuccess{
#checking if the registry path exists and creating one if doesn't exist
If (!(Test-Path "HKLM:\Software\TI")) {
	        New-Item -Path "HKLM:\Software\TI" -Force | Out-Null
        }
        elseif(!(Test-Path "HKLM:\Software\TI\HWupdateTrigger")) {
	        New-Item -Path "HKLM:\Software\TI\HWupdateTrigger" -Force | Out-Null
        }
Set-ItemProperty -path HKLM:\SOFTWARE\TI\HWupdateTrigger -Name Trigger -Value Success -Type String -ErrorAction Stop
write-host "Registry updated for Trigger for Success"
Set-ItemProperty -path HKLM:\SOFTWARE\TI\HWupdateTrigger -Name TriggeredDate -Value $currentdate -Type String -ErrorAction Stop
write-host "Registry updated for Date"

}

Function RegistrySettingsFailure{
#checking if the registry path exists and creating one if doesn't exist
If (!(Test-Path "HKLM:\Software\TI")) {
	        New-Item -Path "HKLM:\Software\TI" -Force | Out-Null
        }
        elseif(!(Test-Path "HKLM:\Software\TI\HWupdateTrigger")) {
	        New-Item -Path "HKLM:\Software\TI\HWupdateTrigger" -Force | Out-Null
        }
Set-ItemProperty -path HKLM:\SOFTWARE\TI\HWupdateTrigger -Name Trigger -Value Failure -Type String -ErrorAction Stop
write-host "Registry updated for Trigger for failure"
Set-ItemProperty -path HKLM:\SOFTWARE\TI\HWupdateTrigger -Name TriggeredDate -Value $currentdate -Type String -ErrorAction Stop
write-host "Registry updated for Date"

}



#Function to check the Dell log files
Function Dell_log{
try{
#$pathloc_dell= $path_dell
$lastwritetime=((get-item $log_dell).LastWriteTime.date).ToString('dd/MM/yyyy')
$currentdate=(get-date).ToString('dd/MM/yyyy')
if($lastwritetime -eq $currentdate){
write-host "Log file date matches"
$loginfo=get-content $log_dell
if($loginfo -match "The program exited with return code:"){
write-host "Task run successfully"
RegistrySettingsSuccess
#return $true
}
}
}
catch{
 Write-Warning $_.Exception.Message
 RegistrySettingsFailure
}
}


Function HP_log{

try{
#$pathloc= $path_hp
$lastwritetime=((get-item $log_hp).LastWriteTime.date).ToString('dd/MM/yyyy')
$currentdate=(get-date).ToString('dd/MM/yyyy')
if($lastwritetime -eq $currentdate){
write-host "Log file date matches"
$loginfo=get-content $log_hp
if($loginfo -match "Exiting with exit code:"){
write-host "Task run successfully"
RegistrySettingsSuccess
#return $true
}
}
}
catch{
 Write-Warning $_.Exception.Message
 RegistrySettingsFailure
}
}



#check if the machine is online 
$Fqdn = [System.Net.Dns]::GetHostByName($env:computername).HostName
if(test-connection -computername $fqdn -quiet)
{  

# Get current user session
$interactiveSessions = quser | Select-String -Pattern "Active"

# Check if there are any interactive user sessions
if ($interactiveSessions) {
    Write-Output "User session is active"
} else {
    Write-Output "User session is not active, exiting.."
    exit
}
}

else{
Write-Output "System is offline, exiting.."
exit
}

 <#checking if it is a laptop  
$Pctype=(get-wmiobject win32_computersystem).pcsystemtype
   if($pctype -eq 2)
      {
        write-host("This system is a laptop") 
      }
        else
        { 
			write-host "System is not laptop, exiting.."
            exit
        }#>


#checking if the machine is part of any exception group
$hname=$env:computername+'$'
$hwexception= net group 'Exception-HWupdate' /domain
if(($hwexception | where { $_.contains($hname.ToUpper())})){
#if($hwexception -contains $hname){
write-host "This machine is in the exception group.. Exiting"
exit
}

$unsupported= net group 'Exception-UnSupportedHW' /domain
if($unsupported |  where { $_.contains($hname.ToUpper())}){
write-host "This machine is in the  unsupported exception group.. Exiting"
exit
}


#$dir= "$CurrentDir"
$dell_Dir= Join-Path $currentDir "DCU_Update.bat"
$hp_Dir= Join-Path $CurrentDir "hpia.bat"



#Main
#Checking if it is Dell 
try{
if ((Get-WmiObject Win32_ComputerSystem).manufacturer -like "Dell*")
{
    $path_dell= findpath-Dell
    $wrk_dir_dell=$path_dell.TrimEnd("dcu-cli.exe")
    start-process -filepath $dell_Dir -wait -workingDirectory $wrk_dir_dell -nonewwindow
    Dell_notfiy
    Dell_log

   }
   }
   catch{
    Write-Warning $_.Exception.Message
   
   }
   


#Checking if it is HP 
try{
if ((Get-WmiObject Win32_ComputerSystem).manufacturer -like "*HP*"){
    $path_hp=findpath-HP
    $wrk_dir_hp=$path_hp.TrimEnd("HPImageAssistant.exe")
#Checking if the hp process is running
$hp = Get-Process hpimageassistant -ErrorAction SilentlyContinue
if($hp -ne $null){

taskkill /IM HPImageAssistant.exe /f
taskkill /IM HPImageAssistant.dll /f
}

    start-process -FilePath $hp_Dir -wait -WorkingDirectory $wrk_dir_hp -NoNewWindow
    HP_notfiy
    HP_log
    }   
}
catch{
Write-Warning $_.Exception.Message
}

if ($curexpol -eq "Restricted"){
$finexpol=Set-ExecutionPolicy Resrticted
write-host "Reverted executionpolicy is" $finexpol
}
else 
{write-host "Reverted executionpolicy is" $curexpol}

stop-transcript

