# ==============================
# WinForms Designer (UI Layout)
# ==============================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ---- Main Form ----
$form = New-Object Windows.Forms.Form
$form.Text = "About DWindows"
$form.Size = New-Object Drawing.Size(550,750)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::MediumPurple

# ---- Title ----
$titleLabel = New-Object Windows.Forms.Label
$titleLabel.Text = "About DWindows"
$titleLabel.ForeColor = [System.Drawing.Color]::White
$titleLabel.Font = New-Object Drawing.Font("Segoe UI",18,[Drawing.FontStyle]::Bold)
$titleLabel.AutoSize = $true
$titleLabel.Location = New-Object Drawing.Point(150,20)
$form.Controls.Add($titleLabel)

# ---- PictureBoxes ----
$ProgramIcon = New-Object Windows.Forms.PictureBox
$ProgramIcon.SizeMode = 'AutoSize'
$ProgramIcon.Location = New-Object Drawing.Point(20,80)
$form.Controls.Add($ProgramIcon)

$OwnerIcon = New-Object Windows.Forms.PictureBox
$OwnerIcon.SizeMode = 'AutoSize'
$OwnerIcon.Location = New-Object Drawing.Point(20,230)
$form.Controls.Add($OwnerIcon)

$SupportIcon = New-Object Windows.Forms.PictureBox
$SupportIcon.SizeMode = 'AutoSize'
$SupportIcon.Location = New-Object Drawing.Point(20,400)
$form.Controls.Add($SupportIcon)

$SystemIcon = New-Object Windows.Forms.PictureBox
$SystemIcon.SizeMode = 'AutoSize'
$SystemIcon.Location = New-Object Drawing.Point(20,510)
$SystemIcon.Visible = $false
$form.Controls.Add($SystemIcon)

$LicenseIcon = New-Object Windows.Forms.PictureBox
$LicenseIcon.SizeMode = 'AutoSize'
$LicenseIcon.Location = New-Object Drawing.Point(20,560)
$LicenseIcon.Visible = $false
$form.Controls.Add($LicenseIcon)

# ---- Labels (static text) ----
$SoftwareLabel = New-Object Windows.Forms.Label
$SoftwareLabel.ForeColor = [System.Drawing.Color]::White
$SoftwareLabel.Font = New-Object Drawing.Font("Segoe UI",12,[Drawing.FontStyle]::Bold)
$SoftwareLabel.AutoSize = $true
$SoftwareLabel.Location = New-Object Drawing.Point(50,80)
$form.Controls.Add($SoftwareLabel)

$OwnerLabel = New-Object Windows.Forms.Label
$OwnerLabel.ForeColor = [System.Drawing.Color]::White
$OwnerLabel.Font = New-Object Drawing.Font("Segoe UI",12,[Drawing.FontStyle]::Bold)
$OwnerLabel.AutoSize = $true
$OwnerLabel.Location = New-Object Drawing.Point(50,230)
$form.Controls.Add($OwnerLabel)

$SupportLabel = New-Object Windows.Forms.Label
$SupportLabel.ForeColor = [System.Drawing.Color]::White
$SupportLabel.Font = New-Object Drawing.Font("Segoe UI",12,[Drawing.FontStyle]::Bold)
$SupportLabel.AutoSize = $true
$SupportLabel.Location = New-Object Drawing.Point(50,400)
$form.Controls.Add($SupportLabel)

$SystemLabel = New-Object Windows.Forms.Label
$SystemLabel.ForeColor = [System.Drawing.Color]::White
$SystemLabel.Font = New-Object Drawing.Font("Segoe UI",12,[Drawing.FontStyle]::Bold)
$SystemLabel.AutoSize = $true
$SystemLabel.Location = New-Object Drawing.Point(50,510)
$SystemLabel.Visible = $false
$form.Controls.Add($SystemLabel)

$LicenseLabel = New-Object Windows.Forms.Label
$LicenseLabel.ForeColor = [System.Drawing.Color]::White
$LicenseLabel.Font = New-Object Drawing.Font("Segoe UI",12,[Drawing.FontStyle]::Bold)
$LicenseLabel.AutoSize = $true
$LicenseLabel.Location = New-Object Drawing.Point(50,560)
$LicenseLabel.Visible = $false
$form.Controls.Add($LicenseLabel)

# ---- Buttons ----
$mainButton = New-Object Windows.Forms.Button
$mainButton.Text = "I Rat it!"
$mainButton.BackColor = [System.Drawing.Color]::LightSkyBlue
$mainButton.Size = New-Object Drawing.Size(140,40)
$mainButton.Location = New-Object Drawing.Point(205,670)
$form.Controls.Add($mainButton)

$sysBtn = New-Object Windows.Forms.Button
$sysBtn.Text = "System Specs"
$sysBtn.Size = New-Object Drawing.Size(120,35)
$sysBtn.Location = New-Object Drawing.Point(20,635)
$form.Controls.Add($sysBtn)

$licBtn = New-Object Windows.Forms.Button
$licBtn.Text = "License"
$licBtn.Size = New-Object Drawing.Size(120,35)
$licBtn.Location = New-Object Drawing.Point(400,635)
$form.Controls.Add($licBtn)
