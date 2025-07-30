#All the functions
#Function to Validate IP address

function Validate-IP ($strIP)
{
	$bValidIP = $true
	$arrSections = @()
	$arrSections +=$strIP.split(".")
	#firstly, make sure there are 4 sections in the IP address
	if ($arrSections.count -ne 4) {$bValidIP =$false}
	
	#secondly, make sure it only contains numbers and it's between 0-254
	if ($bValidIP)
	{
		[reflection.assembly]::LoadWithPartialName("'Microsoft.VisualBasic") | Out-Null
		foreach ($item in $arrSections)
		{
			if (!([Microsoft.VisualBasic.Information]::isnumeric($item))) {$bValidIP = $false}
		}
	}
	
	if ($bValidIP)
	{
		foreach ($item in $arrSections)
		{
			$item = [int]$item
			if ($item -lt 0 -or $item -gt 255) {$bValidIP = $false}
		}
	}
	
	Return $bValidIP
}


#Function to Validate SubnetMask

function Validate-SubnetMask ($strSubnetMask)
{
	$bValidMask = $true
	$arrSections = @()
	$arrSections +=$strSubnetMask.split(".")
	#firstly, make sure there are 4 sections in the subnet mask
	if ($arrSections.count -ne 4) {$bValidMask =$false}
	
	#secondly, make sure it only contains numbers and it's between 0-255
	if ($bValidMask)
	{
		[reflection.assembly]::LoadWithPartialName("'Microsoft.VisualBasic") | Out-Null
		foreach ($item in $arrSections)
		{
			if (!([Microsoft.VisualBasic.Information]::isnumeric($item))) {$bValidMask = $false}
		}
	}
	
	if ($bValidMask)
	{
		foreach ($item in $arrSections)
		{
			$item = [int]$item
			if ($item -lt 0 -or $item -gt 255) {$bValidMask = $false}
		}
	}
	
	#lastly, make sure it is actually a subnet mask when converted into binary format
	if ($bValidMask)
	{
		foreach ($item in $arrSections)
		{
			$binary = [Convert]::ToString($item,2)
			if ($binary.length -lt 8)
			{
				do {
				$binary = "0$binary"
				} while ($binary.length -lt 8)
			}
			$strFullBinary = $strFullBinary+$binary
		}
		if ($strFullBinary.contains("01")) {$bValidMask = $false}
		if ($bValidMask)
		{
			$strFullBinary = $strFullBinary.replace("10", "1.0")
			if ((($strFullBinary.split(".")).count -ne 2)) {$bValidMask = $false}
		}
	}
	Return $bValidMask
}

#Function to Convert to Binary (Final Stage)

function ConvertTo-Binary ($strDecimal)
{
	$strBinary = [Convert]::ToString($strDecimal, 2)
	if ($strBinary.length -lt 8)
	{
		while ($strBinary.length -lt 8)
		{
			$strBinary = "0"+$strBinary
		}
	}
	Return $strBinary
}

#Function to Convert IP to Binary

function Convert-IP-To-Binary ($strIP)
{
	$strBinaryIP = $null
	if (Validate-IP $strIP)
	{
		$arrSections = @()
		$arrSections += $strIP.split(".")
		foreach ($section in $arrSections)
		{
			if ($strBinaryIP -ne $null)
			{
				$strBinaryIP = $strBinaryIP+"."
			}
				$strBinaryIP = $strBinaryIP+(ConvertTo-Binary $section)
			
		}
	}
	Return $strBinaryIP
}


#Function to Convert SubnetMask to Binary
 
Function Convert-SubnetMask-To-Binary ($strSubnetMask)
{
		$strBinarySubnetMask = $null
	if (Validate-SubnetMask $strSubnetMask)
	{
		$arrSections = @()
		$arrSections += $strSubnetMask.split(".")
		foreach ($section in $arrSections)
		{
			if ($strBinarySubnetMask -ne $null)
			{
				$strBinarySubnetMask = $strBinarySubnetMask+"."
			}
				$strBinarySubnetMask = $strBinarySubnetMask+(ConvertTo-Binary $section)
			
		}
	}
	Return $strBinarySubnetMask
}

#Function to Convert BinaryIP Address at the end
Function Convert-BinaryIPAddress ($BinaryIP)
{
	$FirstSection = [Convert]::ToInt64(($BinaryIP.substring(0, 8)),2)
	$SecondSection = [Convert]::ToInt64(($BinaryIP.substring(8,8)),2)
	$ThirdSection = [Convert]::ToInt64(($BinaryIP.substring(16,8)),2)
	$FourthSection = [Convert]::ToInt64(($BinaryIP.substring(24,8)),2)
	$strIP = "$FirstSection`.$SecondSection`.$ThirdSection`.$FourthSection"
	Return $strIP
}

#function to get the details of mp and dp information using the hash 
function get-MPDP($sitecode){

$mp_dp=@()
$sitetoMPDP=@{

"AF"="Austin","United States","Americas","LEW - MP","LEW - Content"
"AI"="Cha-cherng-Sao","Thailand","Asia","QSW - MP","QSW - Content"
"AN"="Xian","China","Asia","QSW - MP","QSW - Content"
"AO"="Aguascalientes","Mexico","Americas","LEW - MP","AO - Content"
"AR"="Hsinchu","Taiwan, Province of China","Asia","QSW - MP","QSW - Content"
"BA"="2600 Baguio City,  Philippines","Philippines","Asia","QSW - MP","BA - Content"
"BD"="Bangalore","India","Asia","QSW - MP","BD - Content"
"BM"="Bloomington","United States","Americas","LEW - MP","LEW - Content"
"BX"="Bangkok","Thailand","Asia","QSW - MP","QSW - Content"
"CD"="Chengdu City,","China","Asia","QSW - MP","CC - Content"
"CE"="Carmel","United States","Americas","LEW - MP","LEW - Content"
"CH"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"CL"="Pampanga","Philippines","Asia","QSW - MP","CL - Content"
"CQ"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"CU"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"D5"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"D6"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"DA"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"DC"="Washington, DC","United States","Americas","LEW - MP","LEW - Content"
"DE"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"DK"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"DL"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"DR"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"DV"="Lewisville","United States","Americas","LEW - MP","LEW - Content"
"EE"="Ft. Worth","United States","Americas","LEW - MP","EE - Content"
"ES"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"EU"="","Germany","EMEA","QFW - MP","QFW - Content"
"FD"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"FE"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"FL"="Dallas Texas","United States","Americas","LEW - MP","FL - Content"
"FN"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"FO"="McKinney","United States","Americas","LEW - MP","LEW - Content"
"FR"="Freising","Germany","EMEA","QFW - MP","QFW - Content"
"GA"="Garching","Germany","EMEA","QFW - MP","QFW - Content"
"GB"="Stuttgart","Germany","EMEA","QFW - MP","QFW - Content"
"GF"="Singapore","Singapore","Asia","QSW - MP","QSW - Content"
"GJ"="Guadalajara","Mexico","Americas","LEW - MP","AO - Content"
"HB"="Shanghai","China","Asia","QSW - MP","HU - Content"
"HE"="Helsinki","Finland","EMEA","QFW - MP","QFW - Content"
"HK"="Hong Kong","China","Asia","QSW - MP","QSW - Content"
"HM"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"HS"="The Woodlands","United States","Americas","LEW - MP","LEW - Content"
"HU"="Pudong District","China","Asia","QSW - MP","QSW - Content"
"HV"="Huntsville","United States","Americas","LEW - MP","LEW - Content"
"HX"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"HZ"="Nanshan Dist","China","Asia","QSW - MP","QSW - Content"
"I1"="Kaohsiung","Taiwan, Province of China","Asia","QSW - MP","QSW - Content"
"ID"="New Delhi","India","Asia","QSW - MP","QSW - Content"
"IE"="Pune","India","Asia","QSW - MP","QSW - Content"
"IS"="RAANANA","Israel","EMEA","QFW - MP","IS - Content"
"IV"="Irvine","United States","Americas","LEW - MP","LEW - Content"
"KD"="Dong, Chung-gu  Daegu City","Korea, Republic of","Asia","QSW - MP","QSW - Content"
"KE"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"KL"="Kuala Lumpur","Malaysia","Asia","QSW - MP","KL - Content"
"KN"="Knoxville","United States","Americas","LEW - MP","LEW - Content"
"KW"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"L7"="Lund","Sweden","EMEA","QFW - MP","QFW - Content"
"LE"="Lewisville","United States","Americas","LEW - MP","LEW - Content"
"LS"="Taichung","Taiwan, Province of China","Asia","QSW - MP","QSW - Content"
"M8"="10050 Penang","Malaysia","Asia","QSW - MP","QSW - Content"
"MA"="Madrid","Spain","EMEA","QFW - MP","QFW - Content"
"MH"="Inashiki","Japan","Japan","QJW - MP","MH - Content"
"MI"="Beijing","China","Asia","QSW - MP","BF - Content"
"ML"="VIMERCATE (MI)","Italy","EMEA","QFW - MP","QFW - Content"
"MM"="Lewisville","United States","Americas","LEW - MP","LEW - Content"
"MY"="Manchester","United States","Americas","LEW - MP","LEW - Content"
"NN"="Nagoya","Japan","Japan","QJW - MP","QJ - Content"
"OA"="Osaka-shi","Japan","Japan","QJW - MP","QJ - Content"
"OS"="Oslo","Norway","EMEA","QFW - MP","QFW - Content"
"OT"="Ottawa (Kanata)","Canada","Americas","LEW - MP","LEW - Content"
"P6"="Bicutan Paranaque","Philippines","Asia","QSW - MP","QSW - Content"
"P7"="Laguna","Philippines","Asia","QSW - MP","QSW - Content"
"PG"="Praha","Czechia","EMEA","QFW - MP","QFW - Content"
"PH"="Allen","United States","Americas","LEW - MP","LEW - Content"
"QJ"="Tokyo","Japan","Japan","QJW - MP","QJ - Content"
"QS"="Singapore","Singapore","Asia","QSW - MP","QSW - Content"
"RE"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"RF"="Richardson","United States","Americas","LEW - MP","LEW - Content"
"S9"="Suwon 442-835","Korea, Republic of","Asia","QSW - MP","QSW - Content"
"SB"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"SC"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"SE"="Kangnam-gu","Korea, Republic of","Asia","QSW - MP","QSW - Content"
"SH"="Sherman","United States","Americas","LEW - MP","SH - Content"
"SO"="San Diego","United States","Americas","LEW - MP","LEW - Content"
"SS"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"T1"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"TA"="Chung Ho","Taiwan, Province of China","Asia","QSW - MP","TA - Content"
"TD"="Qingdao","China","Asia","QSW - MP","QSW - Content"
"TE"="Chung Ho City","Taiwan, Province of China","Asia","QSW - MP","TE - Content"
"TH"="Taipei 105405","Taiwan, Province of China","Asia","QSW - MP","TH - Content"
"TI"="Ayuthaya 13160","Thailand","Asia","QSW - MP","QSW - Content"
"TK"="Lung Tan","Taiwan, Province of China","Asia","QSW - MP","QSW - Content"
"TR"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"TS"="Shinagawa-ku","Japan","Japan","QJW - MP","QJ - Content"
"TU"="Istanbul","Turkey","EMEA","QFW - MP","QFW - Content"
"TX"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"UE"="Singapore","Singapore","Asia","QSW - MP","QSW - Content"
"UM"="Lewisville","United States","Americas","LEW - MP","LEW - Content"
"VG"="Wayne","United States","Americas","LEW - MP","LEW - Content"
"VN"="Vienna","Austria","EMEA","QFW - MP","QFW - Content"
"WC"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"WH"="Wuhan","China","Asia","QSW - MP","QSW - Content"
"WM"="Waltham","United States","Americas","LEW - MP","LEW - Content"
"WP"="Bangalore","India","Asia","QSW - MP","BD - Content"
"X0"="Praha 8","Czechia","EMEA","QFW - MP","QFW - Content"
"XC"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"XD"="Roundrock","United States","Americas","LEW - MP","LEW - Content"
"YR"="Lewisville","United States","Americas","LEW - MP","LEW - Content"
"Z1"="","United States","Americas","LEW - MP","LEW - Content"
"Z2"="","United States","Americas","LEW - MP","LEW - Content"
"ZA"="","","Asia","QSW - MP","QSW - Content"
"ZE"="","Germany","EMEA","QFW - MP","QFW - Content"
"ZU"="Zurich","Switzerland","EMEA","QFW - MP","QFW - Content"
"ZW"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"M6"="Manchester","United Kingdom","EMEA","QFW - MP","QFW - Content"
"LY"="SAINT PRIEST","France","EMEA","QFW - MP","QFW - Content"
"ZH"="","United States","Americas","LEW - MP","LEW - Content"
"EY"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"RG"="DÃ¼sseldorf","Germany","EMEA","QFW - MP","QFW - Content"
"M0"="Matsumoto-shi Nagano","Japan","Japan","QJW - MP","QJ - Content"
"EI"="Eindhoven","Netherlands","EMEA","QFW - MP","QFW - Content"
"GE"="Eschborn","Germany","EMEA","QFW - MP","QFW - Content"
"DO"="Dongguan City, Guangdong Prov","China","Asia","QSW - MP","QSW - Content"
"ZI"="Zhuhai, Guangdong Province P.R. China","China","Asia","QSW - MP","QSW - Content"
"BU"="Budapest","Hungary","EMEA","QFW - MP","QFW - Content"
"WE"="Aguas,Aguascalientes","Mexico","Americas","LEW - MP","AO - Content"
"AJ"="Aizuwakamatsu-shi,  Fukushima","Japan","Japan","QJW - MP","AJ - Content"
"CC"="Chengdu","China","Asia","QSW - MP","CC - Content"
"NA"="Nanjing City","China","Asia","QSW - MP","QSW - Content"
"HA"="Hangzhou City","China","Asia","QSW - MP","QSW - Content"
"SJ"="Suzhou 215123, Jiangsu province, China","China","Asia","QSW - MP","QSW - Content"
"GZ"="Guangzhou 510620, China","China","Asia","QSW - MP","QSW - Content"
"XY"="Xiamen","China","Asia","QSW - MP","QSW - Content"
"V0"="","United States","Americas","LEW - MP","LEW - Content"
"V1"="","United States","Americas","LEW - MP","LEW - Content"
"V2"="","United Kingdom","EMEA","QFW - MP","QFW - Content"
"V3"="","United States","Americas","LEW - MP","LEW - Content"
"V4"="","Australia","Asia","QSW - MP","QSW - Content"
"V5"="","China","Asia","QSW - MP","QSW - Content"
"V6"="","Japan","Japan","QJW - MP","QJ - Content"
"V7"="","United States","Americas","LEW - MP","LEW - Content"
"V8"="","China","Asia","QSW - MP","QSW - Content"
"V9"="","Japan","Japan","QJW - MP","QJ - Content"
"BB"="Issy-Les-Moulineaux","France","EMEA","QFW - MP","QFW - Content"
"A1"="Hsinchu","Taiwan, Province of China","Asia","QSW - MP","QSW - Content"
"TQ"="Taichung","Taiwan, Province of China","Asia","QSW - MP","QSW - Content"
"AK"="Gyeonggi-Do,","Korea, Republic of","Asia","QSW - MP","QSW - Content"
"OF"="Oulu","Finland","EMEA","QFW - MP","QFW - Content"
"WT"="Federal Way","United States","Americas","LEW - MP","LEW - Content"
"NS"="Santa Clara","United States","Americas","LEW - MP","NS - Content"
"ME"="S. Portland","United States","Americas","LEW - MP","LEW - Content"
"MK"="Batu Berendam","Malaysia","Asia","QSW - MP","MK - Content"
"CR"="Phoenix","United States","Americas","LEW - MP","LEW - Content"
"FT"="Ft. Collins","United States","Americas","LEW - MP","LEW - Content"
"LC"="Longmont","United States","Americas","LEW - MP","LEW - Content"
"HP"="Shanghai","China","Asia","QSW - MP","HP - Content"
"XN"="Belgrade","Serbia","EMEA","QFW - MP","QFW - Content"
"BJ"="Beijing.","China","Asia","QSW - MP","BF - Content"
"JC"="Jiangsu","China","Asia","QSW - MP","QSW - Content"
"S5"="Guangzhou","China","Asia","QSW - MP","QSW - Content"
"IF"="Prato","Italy","EMEA","QFW - MP","QFW - Content"
"EX"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"CS"="Changsha Hunan Prov","China","Asia","QSW - MP","QSW - Content"
"HJ"="Hiji-machi Hayami-gun","Japan","Japan","QJW - MP","QJ - Content"
"S6"="Bangkok","Thailand","Asia","QSW - MP","QSW - Content"
"SL"="Sugar Land","United States","Americas","LEW - MP","LEW - Content"
"DS"="Broomfield","United States","Americas","LEW - MP","LEW - Content"
"G4"="","United States","Americas","LEW - MP","LEW - Content"
"TP"="Taoyuan","Taiwan, Province of China","Asia","QSW - MP","TP - Content"
"EZ"="Freising","Germany","EMEA","QFW - MP","QFW - Content"
"H0"="Hannover","Germany","EMEA","QFW - MP","QFW - Content"
"NT"="Northampton","United Kingdom","EMEA","QFW - MP","QFW - Content"
"BO"="Glendale","United States","Americas","LEW - MP","LEW - Content"
"CX"="Bangalore,","India","Asia","QSW - MP","BD - Content"
"RT"="Richardson","United States","Americas","LEW - MP","LEW - Content"
"AT"="Atlanta, GA","United States","Americas","LEW - MP","LEW - Content"
"DX"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"CN"="Cary","United States","Americas","LEW - MP","LEW - Content"
"QF"="Frankfurt","Germany","EMEA","QFW - MP","FR - Content"
"MP"="Tlaquepaque Jalisco","Mexico","Americas","LEW - MP","AO - Content"
"TO"="Toronto","Canada","Americas","LEW - MP","LEW - Content"
"U2"="Nieuwegein","Netherlands","EMEA","QFW - MP","QFW - Content"
"SD"="Southfield","United States","Americas","LEW - MP","LEW - Content"
"S8"="Schaumburg","United States","Americas","LEW - MP","LEW - Content"
"LA"="Los Angeles","United States","Americas","LEW - MP","LEW - Content"
"BC"="Boca Raton","United States","Americas","LEW - MP","LEW - Content"
"IN"="Iselin","United States","Americas","LEW - MP","LEW - Content"
"AZ"="Tucson","United States","Americas","LEW - MP","LEW - Content"
"AW"="","United States","Americas","LEW - MP","LEW - Content"
"J2"="Jiangyin","China","Asia","QSW - MP","QSW - Content"
"R2"="Richardson","United States","Americas","LEW - MP","LEW - Content"
"GI"="Singapore","Singapore","Asia","QSW - MP","QSW - Content"
"BW"="Bellevue","United States","Americas","LEW - MP","LEW - Content"
"SZ"="Nanshan","China","Asia","QSW - MP","QSW - Content"
"QD"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"IH"="Chennai","India","Asia","QSW - MP","QSW - Content"
"SW"="Shanghai","China","Asia","QSW - MP","HU - Content"
"LF"="Lehi","United States","Americas","LEW - MP","Lehi - Content"
"QE"="Frankfurt","Germany","EMEA","QFW - MP","FR - Content"
"LV"="Bangalore","India","Asia","QSW - MP","BD - Content"
"MZ"="","","Americas","LEW - MP","LEW - Content"
"S1"="Sherman","United States","Americas","LEW - MP","SH - Content"
"S2"="Sherman","United States","Americas","LEW - MP","SH - Content"
"S4"="Sherman","United States","Americas","LEW - MP","SH - Content"
"TN"="Tainan","Taiwan, Province of China","Asia","QSW - MP","QSW - Content"
"AU"="Sydney NSW 2170","Australia","Asia","QSW - MP","QSW - Content"
"S3"="Sherman","United States","Americas","LEW - MP","SH - Content"
"NU"="NÃ¼rnberg","Germany","EMEA","QFW - MP","QFW - Content"
"RB"="Regensburg","Germany","EMEA","QFW - MP","QFW - Content"
"S0"="Sherman","United States","Americas","LEW - MP","SH - Content"
"SK"="Kista","Sweden","EMEA","QFW - MP","QFW - Content"
"SM"="Sherman","United States","Americas","LEW - MP","SH - Content"
"ZZ"="Dallas","United States","Americas","LEW - MP","LEW - Content"
"M2"="Batu Berendam","Malaysia","Asia","QSW - MP","MK - Content"
"NR"="Bangalore","India","Asia","QSW - MP","BD - Content"
"QX"="Garland","United States","Americas","LEW - MP","LEW - Content"
"FP"="Dreieich","Germany","EMEA","QFW - MP","QFW - Content"
"RA"="Ra'anana","Israel","EMEA","QFW - MP","IS - Content"
"KP"="Kaula Lampur","Malaysia","Asia","QSW-MP","KL - Content"
"NC"="Santa Clara","United States","Americas","LEW - MP","NS - Content"
"CA"="Bangalore","India","Asia","QSW - MP","BD - Content"
}

if ($sitetoMPDP.containskey($sitecode))
{
$mp_dp+=[PSCustomObject]@{

MP=($sitetoMPDP.($sitecode))[3]
DP=($sitetoMPDP.($sitecode))[4]
}
return $mp_dp
}
else{$mp_dp+=[PSCustomObject]@{

MP="Null"
DP="Null"
}
return $mp_dp
}
}


#Function to delete the dump which is more than 14 days old
Function Deletion(){
$a=get-date -date(get-date).AddDays(-14)
$b=get-childitem -path "E:\Automation\Prod\Infoblox Discovery"
foreach($x in $b){
if ($x.lastwritetime -le $a)
{ 
$f=$x.name
remove-item  -path "E:\Automation\Prod\Infoblox Discovery\$f*" -Force  
}}}


# This part is for the switch statement to segregatet the <= and >= side indicators.
try{
$out=@()
$today = get-date -format "dd-MM-yyyy"
$yesterday = Get-Date -Date (Get-Date).AddDays(-7) -Format "dd-MM-yyyy"
$file1 = import-csv -Path "E:\Automation\Prod\Infoblox Discovery\$today*" 
$file2 = import-csv -Path "E:\Automation\Prod\Infoblox Discovery\$yesterday*"
#$res=compare-object -ReferenceObject $file2 -differenceobject $file1 -property address

If($file1 -and $file2 ){
    #Write-Host ("File Exists")
     Deletion
    $res=Compare-Object -referenceobject $file1 -differenceobject $file2 -property address
   
   If($res){
    $out+=foreach($x in $res){

    switch($x.SideIndicator){
    
    '<=' {
    $ch=@($file1|Where-Object {$_.address -eq $x.address})[0]
    [pscustomobject]@{
    Address=$ch.address
    Bitmask=$ch.bitmask
    Subnetmask=$ch.netmask
    Description= $ch.comment
    Comment="IP address added"
    }}

     '=>'{
    $ch1=@($file2|Where-Object {$_.address -eq $x.address})[0]
    [pscustomobject]@{
    Address=$ch1.address
    Bitmask=$ch1.bitmask
    Subnetmask=$ch1.netmask
    Description= $ch1.comment
    Comment="IP address removed"
    }} 
  }}}}

  #This part of the code goes through multiple functions iteratively and creates iprange.
   $final=@()
  foreach ($i in $out){
 
  $BinarySubnetMask = (Convert-SubnetMask-To-Binary $i.subnetmask).replace(".", "")
	$BinaryNetworkAddressSection = $BinarySubnetMask.replace("1", "")
	$BinaryNetworkAddressLength = $BinaryNetworkAddressSection.length
	$CIDR = 32 - $BinaryNetworkAddressLength
	$iAddressWidth = [System.Math]::Pow(2, $BinaryNetworkLength)
	$iAddressPool = $iAddressWidth -2
    $BinaryIP = (Convert-IP-To-Binary $i.address).Replace(".", "")
	$BinaryIPNetworkSection = $BinaryIP.substring(0, $CIDR)
	$BinaryIPAddressSection = $BinaryIP.substring($CIDR, $BinaryNetworkAddressLength)

	
	#Starting IP
	$FirstAddress = $BinaryNetworkAddressSection -replace "0$", "1"
	$BinaryFirstAddress = $BinaryIPNetworkSection + $FirstAddress
	$strFirstIP = Convert-BinaryIPAddress $BinaryFirstAddress
	
	#End IP
	$LastAddress = ($BinaryNetworkAddressSection -replace "0", "1") -replace "1$", "0"
	$BinaryLastAddress = $BinaryIPNetworkSection + $LastAddress
	$strLastIP = Convert-BinaryIPAddress $BinaryLastAddress
$final+=$strFirstIP+"-"+$strLastIP
  
  }
 
   
 #Getting MP_DP information
 $Mp_DPData=@()
 $patterns=@('Hyper','VM','vSphere','Datacenter','Netbackup','Reverse Proxies','Console','Switch','Infrastructure Utility','Data center','Ribloe','TermServ','iDRAC','ESXi','Terminal Server',
               'Server','Srvr','Autostore','Oracle Cloud','TMG Veeam Greenfield','Colo','V-Motion')
  foreach($des in $out){
    $description = $des.description
$matched = $false

# 1. Check if Description is empty or null
if ([string]::IsNullOrWhiteSpace($description)) {
    $Mp_DPData += [PSCustomObject]@{
        MP = "No Description"
        DP = "No Description"
    }
    $matched = $true
}

# 2. Check against known patterns (only if not already matched)
elseif (-not $matched) {
    foreach ($pattern in $patterns) {
        if ($description -match $pattern -or $description -match '(\bDC\b|DC\w+|\d+\\DC)') {
            $scode_sr = $description.Substring(0, 2)
            $Mp_DPData += get-MPDP $scode_sr | ForEach-Object {
                $_.MP = "SR1"
                $_
            }
            $matched = $true
            break
        }
    }
}

# 3. DMZ pattern check (only if not already matched)
if (-not $matched -and $description -match 'DMZ') {
    $Mp_DPData += [PSCustomObject]@{
        MP = "SR1"
        DP = "DMZ - Content (SRV)"
    }
    $matched = $true
}

# 4. Final fallback (only if still not matched)
if (-not $matched) {
    $scode = $description.Substring(0, 2)
    $Mp_DPData += get-MPDP $scode
}
}


  # Creating another pscustomobject for the final result.
  $combined=@()
  $combined = for($p=0; $p -lt $out.length; $p++)
  {
 [PSCustomObject]@{
  Address=$out[$p].address
  Bitmask=$out[$p].Bitmask
  Subnetmask=$out[$p].subnetmask
  Description=$out[$p].Description
  Comment=$out[$p].Comment
  IPrange=$final[$p]
  MP=$Mp_DPData[$p].MP
  DP=$Mp_DPData[$p].DP
   }
  }}

  catch{
    $subj="Error in Infoblox IP modification at $today"
    Send-MailMessage -from sccm_subnetmonitoring@list.ti.com -Subject $subj -To sccm_l2@list.ti.com -Body $($_.Exception.Message) -BodyAsHtml  -DeliveryNotificationOption OnFailure -SmtpServer smtp.mail.ti.com
   }  
  
# sending an email
 $date=get-date -Format "dd-MM-yyyy HH:mm:ss"
 $mailsub="Infoblox IP modification at $date"
 $Header = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@
$mailbody2=@"
No IP Modification this week.
"@

$mailbody=

$combined  | select address, description,Bitmask,Subnetmask, comment, IPrange, MP, DP | ConvertTo-Html -head $header | Out-String 


Try 
{
If($combined){
    Send-MailMessage -from sccm_subnetmonitoring@list.ti.com -Subject $Mailsub -To sccm_l2@list.ti.com  -Body $mailbody -BodyAsHtml  -DeliveryNotificationOption OnFailure -SmtpServer smtp.mail.ti.com }

else{
Send-MailMessage -from sccm_subnetmonitoring@list.ti.com -Subject $Mailsub -To sccm_l2@list.ti.com -Body $mailbody2  -DeliveryNotificationOption OnFailure -SmtpServer smtp.mail.ti.com }
}
Catch 
{
    Send-MailMessage -from sccm_subnetmonitoring@list.ti.com -Subject Exception -To sccm_l2@list.ti.com  -Body $_.Exception.Message  -DeliveryNotificationOption OnFailure -SmtpServer smtp.mail.ti.com 
    #Write-Warning "Exception Type: $($_.Exception.GetType().FullName)" 
    #Write-Warning "Exception Message: $($_.Exception.Message)"
}

Exit




    