# ==============================
# Load Designer
# ==============================
. "$PSScriptRoot\DWinver.Designer.ps1"

# ==============================
# System Info (fixed order)
# ==============================
$OS  = (Get-CimInstance Win32_OperatingSystem).Caption
$CPU = (Get-CimInstance Win32_Processor).Name
$RAM = "{0:N2}" -f ((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory/1GB) + " GB"

# ==============================
# Software Info
# ==============================
$AppName     = "D" + $OS
$Version     = "DWinVer 2.0"
$Company     = "Dev Setup"
$Author      = "Dev0630"
$ReleaseDate = "October 1, 2024"
$Description = "Fish"
$Copyright   = "© Copyright Dev Setup — All Rats Reserved!"
$ButtonText  = "I Rat it!"

# Registry
$regPath = "HKCU:\Software\DWindows"
if (-not (Test-Path $regPath)) { New-Item -Path $regPath | Out-Null }

# ==============================
# Assembly Resource Loader
# ==============================
$projectRoot = $PSScriptRoot
$assemblyPath = Get-ChildItem -Path "$projectRoot\bin" -Recurse -Filter "DWinver*.exe" |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $assemblyPath) { throw "Assembly not found. Build first!" }

Add-Type -Path $assemblyPath.FullName

function Get-Resource([string]$name) {
    return [DWinver.Properties.Resources]::$name
}

# ==============================
# Assign Icons
# ==============================
$ProgramIcon.Image = Get-Resource "programdata"
$OwnerIcon.Image   = Get-Resource "owner"
$SupportIcon.Image = Get-Resource "support"
$SystemIcon.Image  = Get-Resource "systeminfo"
$LicenseIcon.Image = Get-Resource "license"

# ==============================
# Insert Data Into Labels
# ==============================
$SoftwareLabel.Text = @"
--- Software Information ---
$AppName
$Version
$Company
$ReleaseDate
$Description
$Copyright
"@

$OwnerLabel.Text = @"
--- Owner Information ---
Computer: $env:COMPUTERNAME
Username: $env:USERNAME
"@

$SupportLabel.Text = @"
--- Support Information ---
Name: Dev0630
Company: Dev Setup
Email: vkdg0410@gmail.com
Phone: +36204927891
"@

$SystemLabel.Text = @"
--- System Specs ---
OS: $OS
CPU: $CPU
RAM: $RAM
"@

$LicenseLabel.Text = @"
--- License ---
Product keys will come out in V-3.0!
"@

# ==============================
# Button Logic
# ==============================
$mainButton.Add_Click({ $form.Close() })

$sysBtn.Add_Click({
    $SystemLabel.Visible = -not $SystemLabel.Visible
    $SystemIcon.Visible  = $SystemLabel.Visible
})

$licBtn.Add_Click({
    $LicenseLabel.Visible = -not $LicenseLabel.Visible
    $LicenseIcon.Visible  = $LicenseLabel.Visible
})

# ==============================
# Show UI
# ==============================
[void]$form.ShowDialog()
