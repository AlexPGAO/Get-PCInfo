# Get-PCInfo

A PowerShell script that collects key hardware and Windows details from a PC in a few seconds, then saves a report to the desktop.

It's built for quick IT checks: inventorying a machine, confirming Windows 11 readiness (TPM 2.0 and Secure Boot), or grabbing a serial number before a warranty call.

## What it collects

| Field | Source |
|---|---|
| Computer name | Environment |
| Manufacturer and model | `Win32_ComputerSystem` |
| Serial number | `Win32_BIOS` |
| BIOS version | `Win32_BIOS` |
| Processor | `Win32_Processor` |
| Memory (GB) | `Win32_ComputerSystem` |
| Disk size (GB) | `Win32_DiskDrive` (first disk) |
| Windows edition and build | `Win32_OperatingSystem` |
| Secure Boot status | `Confirm-SecureBootUEFI` |
| TPM version | `Win32_Tpm` |
| Date of the report | `Get-Date` |

## Requirements

- Windows 10 or 11
- Windows PowerShell 5.1 or PowerShell 7+
- An administrator PowerShell window (needed for the Secure Boot and TPM checks)

## Usage

1. Download `Get-PCInfo.ps1`.
2. Open PowerShell **as administrator**.
3. Go to the folder with the script and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\Get-PCInfo.ps1
```

`-ExecutionPolicy Bypass` applies only to this one run and doesn't change the system's policy.

For built-in help:

```powershell
Get-Help .\Get-PCInfo.ps1
```

## Output

The results print to the screen and save to `COMPUTERNAME-info.txt` on the desktop. The script uses Windows' own desktop path, so it also works when the desktop is redirected to OneDrive.

Sample output (placeholder values):

```
ComputerName : DESKTOP-EXAMPLE
Manufacturer : Dell Inc.
Model        : OptiPlex 7090
SerialNumber : ABC1234
BIOSVersion  : 1.15.0
Processor    : Intel(R) Core(TM) i5-10500 CPU @ 3.10GHz
MemoryGB     : 16
DiskGB       : 477
Windows      : Microsoft Windows 11 Pro (build 22631)
SecureBoot   : True
TPMVersion   : 2.0, 0, 1.38
Date         : 2026-10-27 08:45

Saved to C:\Users\example\Desktop\DESKTOP-EXAMPLE-info.txt
```

## Notes

- **Not run as administrator?** Secure Boot and TPM show a "Not found / Unknown" message instead of failing. Everything else still works.
- **Legacy BIOS systems** report Secure Boot as unknown, since Secure Boot needs UEFI.
- **Multiple disks:** only the first physical disk is reported.
- **TPM version** is shown as Windows reports it. The first number is the highest version supported, so `2.0, ...` means TPM 2.0.

## Possible improvements

- Query multiple PCs remotely and export to CSV for an inventory sheet
- List all disks, not just the first
- Add network details (IP and MAC address)

## Author

Alex Page ([AlexPGAO](https://github.com/AlexPGAO))
