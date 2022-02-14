#Check to see that VPN is installed
If (!(Test-Path -Path "C:\Program Files (x86)\Sophos\Connect\GUI\scgui.exe")){
    Write-Host "Sophos connect is not installed. Exiting"
    exit 0
}


#Check that the connection doesn't already exist so it won't be overwritten
$connectionList = & 'C:\Program Files (x86)\Sophos\Connect\sccli.exe' list

#Update this line to have the correct vpn hostname
$connectionCheck = @("VPNHOSTNAME.DOMAIN.TLD ---- CHANGE ME!")
foreach ($check in $connectionCheck) {
    if ($connectionList -like "*$check*" ) {
        Write-Host "The connection list contains $check"
        Write-Host "Nothing more to do. Exiting"
        exit 0
    }    
    else {
        Write-Host "The connection list does not contain $check"
        Write-Host "Adding VPN Profile"
		$vpnFile = [PSCustomObject]@{
#Update the next two lines to contain the vpn hostname
      display_name = "VPNHOSTNAME.DOMAIN.TLD ---- CHANGE ME!"
			gateway = "VPNHOSTNAME.DOMAIN.TLD ---- CHANGE ME!"
			otp = $true
			'2fa' = 1
			auto_connect_host = ""
			can_save_credentials = $false
			check_remote_availability = $false
			run_logon_script = $false
		}
		$vpnFile | Add-Member -MemberType NoteProperty -Name "user_portal_port" -Value 1443

		Write-Output "`nCreating VPN Provisioning file with the following:"
		$vpnFile

		if (!(Test-Path "C:\temp\SophosConnect\")) {
		New-Item -Path "C:\temp\SophosConnect\" -ItemType Directory
		}

		$vpnFile | ConvertTo-Json | Out-File "C:\temp\SophosConnect\vpnImport.pro" -Encoding utf8
		Copy-Item -Path "C:\temp\SophosConnect\vpnImport.pro" -Destination "C:\Program Files (x86)\Sophos\Connect\import\"

		Write-Host "VPN profile moved to Sophos import folder"
		}
}
