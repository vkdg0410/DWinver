$DWinver_Load = {

}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ==============================
# Software Information
# ==============================
$AppName      = "D" + $OS
$Version      = "DWinVer 2.0"
$Company      = "Dev Setup"
$Author       = "Dev0630"
$ReleaseDate  = "October 1, 2024"
$Description  = "Fish"
$Copyright    = "� Copyright Dev Setup All Rats reserved!"
$ButtonText   = "I Rat it!"

# Owner Info
$ComputerName = $env:COMPUTERNAME

# System Specs
$OS           = (Get-CimInstance Win32_OperatingSystem).Caption
$CPU          = (Get-CimInstance Win32_Processor).Name
$RAM          = "{0:N2}" -f ((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory/1GB) + " GB"

# License
$License      = "Product keys will come out in V-3.0!"

# Support Info
$SupportName    = "Vagvolgyi-Krucso David Gabor"
$SupportCompany = "Dev Setup"
$SupportEmail   = "vkdg0410@gmail.com"
$SupportPhone   = "+36204927891"

# ==============================
# Registry path for owner info
# ==============================
$regPath = "HKCU:\Software\DWindows"
If (-not (Test-Path $regPath)) { New-Item -Path $regPath | Out-Null }

# ==============================
# Automatically detect compiled assembly
# ==============================
$projectRoot = $PSScriptRoot
$binFolder = Join-Path $projectRoot "bin"
$assemblyPath = Get-ChildItem -Path $binFolder -Recurse -Filter "DWinver*.exe" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $assemblyPath) { throw "Compiled assembly not found. Build your project first!" }

Add-Type -Path $assemblyPath.FullName

# Helper function to get embedded resource images/icons
function Get-Resource([string]$name) {
    return [DWinver.Properties.Resources]::$name
}

# ==============================
# Create Main Form
# ==============================
$form = New-Object Windows.Forms.Form
$form.Text = "About DWindows"
$form.Size = New-Object Drawing.Size(550,750)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::MediumPurple

# --- Title ---
$titleLabel = New-Object Windows.Forms.Label
$titleLabel.Text = "About DWindows"
$titleLabel.ForeColor = [System.Drawing.Color]::White
$titleLabel.Font = New-Object Drawing.Font("Segoe UI",18,[Drawing.FontStyle]::Bold)
$titleLabel.AutoSize = $true
$titleLabel.Location = New-Object Drawing.Point(150,20)
$form.Controls.Add($titleLabel)

# --- Icons and Labels ---
$resources = @{
    ProgramIcon = @{Point=[Drawing.Point]::new(20,80); Resource="programdata"}
    OwnerIcon   = @{Point=[Drawing.Point]::new(20,230); Resource="owner"}
    SupportIcon = @{Point=[Drawing.Point]::new(20,400); Resource="support"}
    SystemIcon  = @{Point=[Drawing.Point]::new(20,510); Resource="systeminfo"; Visible=$false}
    LicenseIcon = @{Point=[Drawing.Point]::new(20,560); Resource="license"; Visible=$false}
}

$labels = @{
    Software    = @{Text=@"
--- Software Information ---
$AppName
$Version
$Company
$ReleaseDate
$Description
$Copyright
"@; Point=[Drawing.Point]::new(50,80)}
    Owner       = @{Text=@"
--- Owner Information ---
Computer: $ComputerName
Username: $env:USERNAME
"@; Point=[Drawing.Point]::new(50,230)}
    Support     = @{Text=@"
--- Support Information ---
Name: $SupportName
Company: $SupportCompany
Email: $SupportEmail
Phone: $SupportPhone
"@; Point=[Drawing.Point]::new(50,400)}
    System      = @{Text=@"
--- System Specs ---
OS: $OS
CPU: $CPU
RAM: $RAM
"@; Point=[Drawing.Point]::new(50,510); Visible=$false}
    License     = @{Text=@"
--- License ---
$License
"@; Point=[Drawing.Point]::new(50,560); Visible=$false}
}

# Create PictureBoxes
foreach ($key in $resources.Keys) {
    $pic = New-Object Windows.Forms.PictureBox
    $pic.SizeMode = 'AutoSize'
    $pic.Location = $resources[$key].Point
    $pic.Image = Get-Resource $resources[$key].Resource
    if ($resources[$key].ContainsKey("Visible")) { $pic.Visible = $resources[$key].Visible }
    $form.Controls.Add($pic)
    Set-Variable $key $pic
}

# Create Labels
foreach ($key in $labels.Keys) {
    $lbl = New-Object Windows.Forms.Label
    $lbl.Text = $labels[$key].Text
    $lbl.ForeColor = [System.Drawing.Color]::White
    $lbl.Font = New-Object Drawing.Font("Segoe UI",12,[Drawing.FontStyle]::Bold)
    $lbl.AutoSize = $true
    $lbl.Location = $labels[$key].Point
    if ($labels[$key].ContainsKey("Visible")) { $lbl.Visible = $labels[$key].Visible }
    $form.Controls.Add($lbl)
    Set-Variable ($key + "Label") $lbl
}

# --- Editable Owner Fields ---
$ownerFields = @{
    Name  = @{Registry="OwnerName"; Y=300}
    Email = @{Registry="OwnerEmail"; Y=335}
    Phone = @{Registry="OwnerPhone"; Y=370}
}

foreach ($field in $ownerFields.Keys) {
    # Label
    $lbl = New-Object Windows.Forms.Label
    $lbl.Text = $field
    $lbl.ForeColor = [System.Drawing.Color]::White
    $lbl.Font = New-Object Drawing.Font("Segoe UI",12,[Drawing.FontStyle]::Bold)
    $lbl.AutoSize = $true
    $lbl.Location = New-Object Drawing.Point(50, $ownerFields[$field].Y)
    $form.Controls.Add($lbl)

    # TextBox
    $txt = New-Object Windows.Forms.TextBox
    $txt.Text = (Get-ItemProperty -Path $regPath -Name $ownerFields[$field].Registry -ErrorAction SilentlyContinue).$($ownerFields[$field].Registry)
    $txt.Font = New-Object Drawing.Font("Segoe UI",12)
    $txt.Size = New-Object Drawing.Size(300,25)
    $txt.Location = New-Object Drawing.Point(150,$ownerFields[$field].Y)
    $txt.Add_Leave({ Set-ItemProperty -Path $regPath -Name $ownerFields[$field].Registry -Value $txt.Text })
    $form.Controls.Add($txt)
}

# --- Buttons ---
$buttonWidth = 140
$buttonHeight = 40
$bottomY = $form.ClientSize.Height - 80
$centerX = [int](($form.ClientSize.Width - $buttonWidth)/2)

$mainButton = New-Object Windows.Forms.Button
$mainButton.Text = $ButtonText
$mainButton.BackColor = [System.Drawing.Color]::LightSkyBlue
$mainButton.Size = New-Object Drawing.Size($buttonWidth,$buttonHeight)
$mainButton.Location = New-Object Drawing.Point($centerX,$bottomY)
$mainButton.Add_Click({ $form.Close() })
$form.Controls.Add($mainButton)

# System Specs toggle
$sysBtn = New-Object Windows.Forms.Button
$sysBtn.Text = "System Specs"
$sysBtn.Size = New-Object Drawing.Size(120,35)
$sysBtn.Location = New-Object Drawing.Point(20,635)
$sysBtn.BackColor = [System.Drawing.Color]::Red
$sysBtn.Add_Click({
    $newState = -not $SystemLabel.Visible
    $SystemLabel.Visible = $newState
    $SystemIcon.Visible = $newState
})
$form.Controls.Add($sysBtn)

# License toggle
$licBtn = New-Object Windows.Forms.Button
$licBtn.Text = "License"
$licBtn.Size = New-Object Drawing.Size(120,35)
$licBtn.Location = New-Object Drawing.Point(400,635)
$licBtn.BackColor = [System.Drawing.Color]::Green
$licBtn.Add_Click({
    $newState = -not $LicenseLabel.Visible
    $LicenseLabel.Visible = $newState
    $LicenseIcon.Visible = $newState
})
$form.Controls.Add($licBtn)

# --- Show Form ---
[void]$form.ShowDialog()
