# Author: Preethi G Salian
# Date created: 7/25/2023
# This script fetches the data from the infoblox API and generates the dump of "networks"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12, [Net.SecurityProtocolType]::Ssl3
[Net.ServicePointManager]::SecurityProtocol = "Tls, Tls11, Tls12, Ssl3"
try{
$defs = Invoke-RestMethod -Uri "https://tiib.itg.ti.com/api/v1/reports/networks.json?key=hVnXyKUBUf33d_MqOqPlhHxAE6JKqFVMLU6b2Csu43Y" -method get
$j = $defs.networks
$today = Get-Date -Format "dd-MM-yyyy_HH_mm_ss"
#$k=$j| select-object *, @{Name = 'Time'; Expression = {(Get-Date -format s)}}
$j|convertto-json -depth 100 |out-file "\\ent.ti.com\data\SCCMContentlibrary\SoftDisc\Client_Baseline2025_1H\Applications\Scripts_2024\subnets_dump.json"
$j|convertto-json -depth 100 |out-file "E:\Automation\Infoblox_Subnet_details\Dump\subnets_dump.json"
#$j|convertto-json -depth 100 |out-file "\\lewvw10prov1.ent.ti.com\e$\Websites\WWWroot\GetWindows\data\networks.json"
}
catch{
if($j=" "){
$subj="Error in Dump Creation at $today"
  Send-MailMessage -from sccm_subnetmonitoring@list.ti.com -Subject $subj -To win-clientbaselineowners@list.ti.com -Body $($_.Exception.Message) -BodyAsHtml  -DeliveryNotificationOption OnFailure -SmtpServer smtp.mail.ti.com 
}exit 
}





