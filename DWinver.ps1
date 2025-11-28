# ==============================
# Load Designer
# ==============================
. "$PSScriptRoot\DWinver.Designer.ps1"

# ==============================
# Detect Debug Mode
# ==============================
$IsDebug = $args -contains "-debug"

function Debug-Log($msg) {
    if ($IsDebug) {
        Write-Host "[DEBUG] $msg"
        if ($DebugTextBox) { $DebugTextBox.AppendText("$msg`r`n") }
        if ($DebugFormTextBox) { $DebugFormTextBox.AppendText("$msg`r`n") }
    }
}

# Create Debug UI if needed
if ($IsDebug) {
    Debug-Log "Debug mode enabled"

    # Small bottom panel
    $DebugTextBox = New-Object Windows.Forms.TextBox
    $DebugTextBox.Multiline = $true
    $DebugTextBox.ScrollBars = "Vertical"
    $DebugTextBox.Size = New-Object Drawing.Size($form.ClientSize.Width,100)
    $DebugTextBox.Location = New-Object Drawing.Point(0,$form.ClientSize.Height - 100)
    $DebugTextBox.BackColor = [System.Drawing.Color]::Black
    $DebugTextBox.ForeColor = [System.Drawing.Color]::Lime
    $DebugTextBox.ReadOnly = $true
    $form.Controls.Add($DebugTextBox)

    # Separate debug window
    $DebugForm = New-Object Windows.Forms.Form
    $DebugForm.Text = "Debug Window"
    $DebugForm.Size = New-Object Drawing.Size(600,400)
    $DebugForm.StartPosition = "CenterScreen"

    $DebugFormTextBox = New-Object Windows.Forms.TextBox
    $DebugFormTextBox.Multiline = $true
    $DebugFormTextBox.Dock = "Fill"
    $DebugFormTextBox.BackColor = [System.Drawing.Color]::Black
    $DebugFormTextBox.ForeColor = [System.Drawing.Color]::Lime
    $DebugFormTextBox.ReadOnly = $true
    $DebugForm.Controls.Add($DebugFormTextBox)

    $DebugForm.Show()
}

# ==============================
# System Info
# ==============================
$OS  = (Get-CimInstance Win32_OperatingSystem).Caption
$CPU = (Get-CimInstance Win32_Processor).Name
$RAM = "{0:N2}" -f ((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory/1GB) + " GB"
Debug-Log "Loaded system info: $OS, $CPU, $RAM"

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

# ==============================
# Registry
# ==============================
$regPath = "HKCU:\Software\DWindows"
if (-not (Test-Path $regPath)) { New-Item -Path $regPath | Out-Null }
Debug-Log "Registry path ensured at $regPath"

# ==============================
# Assembly Resource Loader
# ==============================
$projectRoot = $PSScriptRoot
$assemblyPath = Get-ChildItem -Path "$projectRoot\bin" -Recurse -Filter "DWinver*.exe" |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $assemblyPath) { throw "Assembly not found. Build first!" }
Add-Type -Path $assemblyPath.FullName
Debug-Log "Loaded assembly from $($assemblyPath.FullName)"

function Get-Resource([string]$name) {
    try {
        return [DWinver.Properties.Resources]::$name
    } catch {
        Debug-Log "WARNING: Resource '$name' missing!"
        return $null
    }
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
Name: $Author
Company: $Company
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
# Show Form
# ==============================
[void]$form.ShowDialog()
