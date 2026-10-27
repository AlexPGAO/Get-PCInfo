# Get-PCInfo.ps1
# Collects basic PC details and saves them to a text file on the desktop.
# Run from an administrator PowerShell window so the TPM and Secure Boot checks work:
#   powershell -ExecutionPolicy Bypass -File .\Get-PCInfo.ps1

# --- Gather information from Windows ---
$system = Get-CimInstance Win32_ComputerSystem
$bios   = Get-CimInstance Win32_BIOS
$cpu    = Get-CimInstance Win32_Processor | Select-Object -First 1
$os     = Get-CimInstance Win32_OperatingSystem
$disk   = Get-CimInstance Win32_DiskDrive | Select-Object -First 1
$tpm    = Get-CimInstance -Namespace root\cimv2\Security\MicrosoftTpm -ClassName Win32_Tpm -ErrorAction SilentlyContinue

# --- Secure Boot: True = on, False = off ---
# The check fails on legacy (non-UEFI) systems or without administrator rights,
# so try/catch records a readable message instead of stopping the script.
try {
    $secureBoot = Confirm-SecureBootUEFI -ErrorAction Stop
}
catch {
    $secureBoot = 'Unknown (not UEFI, or not run as administrator)'
}

# --- TPM version (2.0 is required for Windows 11) ---
if ($tpm) {
    $tpmVersion = $tpm.SpecVersion
}
else {
    $tpmVersion = 'Not found (or not run as administrator)'
}

# --- Build one tidy record ---
$report = [PSCustomObject]@{
    ComputerName = $env:COMPUTERNAME
    Manufacturer = $system.Manufacturer
    Model        = $system.Model
    SerialNumber = $bios.SerialNumber
    BIOSVersion  = $bios.SMBIOSBIOSVersion
    Processor    = $cpu.Name
    MemoryGB     = [math]::Round($system.TotalPhysicalMemory / 1GB)
    DiskGB       = [math]::Round($disk.Size / 1GB)
    Windows      = "$($os.Caption) (build $($os.BuildNumber))"
    SecureBoot   = $secureBoot
    TPMVersion   = $tpmVersion
    Date         = Get-Date -Format 'yyyy-MM-dd HH:mm'
}

# --- Show it on screen and save it to the desktop ---
$desktop = [Environment]::GetFolderPath('Desktop')
$outFile = Join-Path $desktop "$env:COMPUTERNAME-info.txt"

$report | Format-List
$report | Format-List | Out-File $outFile

Write-Host "Saved to $outFile"
