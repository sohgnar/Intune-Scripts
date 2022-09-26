## This script will search for and remove an application based on the name of the installed application. 
## This was used to remove Cisco Jabber initially but could be modified to remove alternate apps. 

## Run powershell in 64bit mode so that registry keys get added. 
If ($ENV:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
    Try {
        &"$ENV:WINDIR\SysNative\WindowsPowershell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH
    }
    Catch {
        Throw "Failed to start $PSCOMMANDPATH"
    }
    Exit
}


## Leave a breadcrumb in the registry to tell intune that we already uninstalled this product. 
## This is used for the detection portion of the script after the script has been "installed"
$JabberKeyPath = "HKLM:\SOFTWARE\Cisco\Cisco Jabber\"
If (-Not (Test-Path -Path $JabberKeyPath)) { New-Item -Force -Path $JabberKeyPath }

$RemoveJabber = @{
    "Force" = $true
    "Path"  = "$JabberKeyPath"
    "Type"  = "String"
    "Name"  = "Uninstalled"
    "Value" = '1'
}
Set-ItemProperty @RemoveJabber

## Find Cisco Jabber App
$app = Get-WmiObject -Class Win32_Product | Where-Object { 
    $_.Name -match "Cisco Jabber" 
}

## Uninstall Cisco Jabber
msiexec.exe /x $app.IdentifyingNumber /q /norestart

