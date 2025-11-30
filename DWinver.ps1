# ==============================
# Config
# ==============================
$totalSteps = 26
$currentStep = 0

function Log-Prep([string]$msg) {
    $global:currentStep++
    $time = (Get-Date).ToString("HH:mm:ss")
    $line = ("[{0}] Step {1}/{2}: {3}" -f $time, $global:currentStep, $totalSteps, $msg)
    Write-Host $line
    # append to on-form log if present
    if ($null -ne $global:logBox -and $global:logBox -is [System.Windows.Forms.TextBox]) {
        try {
            $global:logBox.AppendText($line + [Environment]::NewLine) | Out-Null
        } catch { }
    }
}

function Log-Error([string]$where, [string]$msg) {
    $time = (Get-Date).ToString("HH:mm:ss")
    $line = ("[{0}] ERROR in {1}: {2}" -f $time, $where, $msg)
    Write-Host $line
    if ($null -ne $global:logBox -and $global:logBox -is [System.Windows.Forms.TextBox]) {
        try { $global:logBox.AppendText($line + [Environment]::NewLine) | Out-Null } catch {}
    }
}

# ==============================
# 1) Load WinForms/Drawing
# ==============================
try {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    Log-Prep "GUI assemblies loaded"
} catch {
    Log-Error "Assembly load" $_.Exception.Message
}

# ==============================
# 2) System specs (WMI, debugger-safe)
# ==============================
try {
    $osObj  = Get-WmiObject -Class Win32_OperatingSystem  -ErrorAction SilentlyContinue
    $cpuObj = Get-WmiObject -Class Win32_Processor        -ErrorAction SilentlyContinue
    $csObj  = Get-WmiObject -Class Win32_ComputerSystem   -ErrorAction SilentlyContinue

    $OS  = if ($osObj -and $osObj.Caption) { $osObj.Caption } else { "Unknown OS" }
    $CPU = if ($cpuObj -and $cpuObj.Name)   { $cpuObj.Name }   else { "Unknown CPU" }
    $RAM = if ($csObj -and $csObj.TotalPhysicalMemory) { "{0:N2} GB" -f ($csObj.TotalPhysicalMemory / 1GB) } else { "Unknown RAM" }

    Log-Prep "System specs gathered"
} catch {
    Log-Error "System specs" $_.Exception.Message
    $OS="Unknown OS"; $CPU="Unknown CPU"; $RAM="Unknown RAM"
}

# ==============================
# 3) Metadata & owner/support
# ==============================
try {
    $AppName      = "D" + $OS
    $Version      = "DWinVer 2.0"
    $Company      = "Dev Setup"
    $Author       = "Dev0630"
    $ReleaseDate  = "October 1, 2024"
    $Description  = "Fish"
    $Copyright    = "© Copyright Dev Setup — All Rats Reserved!"
    $ButtonText   = "I Rat it!"
    $ComputerName = $env:COMPUTERNAME
    $License      = "Product keys will come out in V-3.0!"
    $SupportName    = "Vagvolgyi-Krucso David Gabor"
    $SupportCompany = "Dev Setup"
    $SupportEmail   = "vkdg0410@gmail.com"
    $SupportPhone   = "+36204927891"
    Log-Prep "Metadata & support initialized"
} catch {
    Log-Error "Metadata init" $_.Exception.Message
}

# ==============================
# 4) Registry path
# ==============================
try {
    $regPath = "HKCU:\Software\DWinver"
    if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }
    Log-Prep "Registry path ensured: $regPath"
} catch {
    Log-Error "Registry" $_.Exception.Message
}

# ==============================
# 5) Resource loader (safe)
# ==============================
function Get-ResourceImage([string]$name) {
    # look for explicit files; avoid passing arrays into Join-Path
    $base = $PSScriptRoot
    $paths = @(
        "$base\Resources\$name.ico",
        "$base\Resources\$name.png",
        "$base\Resources\$name.jpg"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) {
            try {
                $ext = [System.IO.Path]::GetExtension($p).ToLowerInvariant()
                if ($ext -eq ".ico") {
                    try {
                        $ic = New-Object System.Drawing.Icon($p)
                        return $ic.ToBitmap()
                    } catch {
                        return [System.Drawing.Image]::FromFile($p)
                    }
                } else {
                    return [System.Drawing.Image]::FromFile($p)
                }
            } catch {
                Log-Error "Get-ResourceImage" $_.Exception.Message
                return $null
            }
        }
    }
    return $null
}
Log-Prep "Resource loader ready"

# ==============================
# 6) Build Form (layout + log box)
# ==============================
try {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "About DWindows"
    $form.Size = New-Object System.Drawing.Size(560,800)
    $form.StartPosition = "CenterScreen"
    $form.BackColor = [System.Drawing.Color]::MediumPurple
    $form.Font = New-Object System.Drawing.Font("Segoe UI",10)
    $form.SuspendLayout()
    Log-Prep "Form created"
} catch {
    Log-Error "Form create" $_.Exception.Message
}

# on-form log textbox (bottom)
$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Multiline = $true
$logBox.ReadOnly = $true
$logBox.ScrollBars = "Vertical"
$logBox.Size = New-Object System.Drawing.Size(520,140)
$logBox.Location = New-Object System.Drawing.Point(20,620)
$logBox.BackColor = [System.Drawing.Color]::WhiteSmoke
# expose globally so Log-Prep can append
Set-Variable -Name logBox -Value $logBox -Scope Global
$form.Controls.Add($logBox)
Log-Prep "On-form log box added"

# Title
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "About DWindows"
$titleLabel.ForeColor = [System.Drawing.Color]::White
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI",16,[System.Drawing.FontStyle]::Bold)
$titleLabel.AutoSize = $true
$titleLabel.Location = New-Object System.Drawing.Point(160,15)
$form.Controls.Add($titleLabel)
Log-Prep "Title added"

# ==============================
# Icons and labels data
# ==============================
$iconDefs = @{
    ProgramIcon = @{X=20; Y=60; Name="programdata"}
    OwnerIcon   = @{X=20; Y=200; Name="owner"}
    SupportIcon = @{X=20; Y=340; Name="support"}
    SystemIcon  = @{X=20; Y=460; Name="systeminfo"; Visible=$false}
    LicenseIcon = @{X=20; Y=540; Name="license"; Visible=$false}
}

$labelDefs = @{
    Software = @{X=90; Y=60; Text = @"
--- Software Information ---
$AppName
$Version
$Company
$ReleaseDate
$Description
$Copyright
"@}
    Owner = @{X=90; Y=200; Text = @"
--- Owner Information ---
Computer: $ComputerName
Username: $env:USERNAME
"@}
    Support = @{X=90; Y=340; Text = @"
--- Support Information ---
Name: $SupportName
Company: $SupportCompany
Email: $SupportEmail
Phone: $SupportPhone
"@}
    System = @{X=90; Y=460; Text = @"
--- System Specs ---
OS: $OS
CPU: $CPU
RAM: $RAM
"@; Visible = $false}
    License = @{X=90; Y=540; Text = @"
--- License ---
$License
"@; Visible = $false}
}

# create pictureboxes (safe)
foreach ($k in $iconDefs.Keys) {
    try {
        $def = $iconDefs[$k]
        $pb = New-Object System.Windows.Forms.PictureBox
        $pb.SizeMode = 'AutoSize'
        $pb.Location = New-Object System.Drawing.Point($def.X, $def.Y)
        $img = Get-ResourceImage $def.Name
        if ($img -ne $null) { $pb.Image = $img } else {
            # placeholder 32x32 transparent
            $bmp = New-Object System.Drawing.Bitmap 32,32
            $g = [System.Drawing.Graphics]::FromImage($bmp); $g.Clear([System.Drawing.Color]::Transparent); $g.Dispose()
            $pb.Image = $bmp
        }
        if ($def.ContainsKey("Visible") -and -not $def.Visible) { $pb.Visible = $false } 
        $form.Controls.Add($pb)
        Set-Variable -Name $k -Value $pb -Scope Global
        Log-Prep ("PictureBox " + $k + " added")
    } catch {
        Log-Error ("PictureBox " + $k) $_.Exception.Message
    }
}

# create labels
foreach ($k in $labelDefs.Keys) {
    try {
        $def = $labelDefs[$k]
        $lbl = New-Object System.Windows.Forms.Label
        $lbl.Text = $def.Text
        $lbl.ForeColor = [System.Drawing.Color]::White
        $lbl.Font = New-Object System.Drawing.Font("Segoe UI",10,[System.Drawing.FontStyle]::Bold)
        $lbl.AutoSize = $true
        $lbl.Location = New-Object System.Drawing.Point($def.X, $def.Y)
        if ($def.ContainsKey("Visible") -and -not $def.Visible) { $lbl.Visible = $false }
        $form.Controls.Add($lbl)
        Set-Variable -Name ($k + "Label") -Value $lbl -Scope Global
        Log-Prep ("Label " + $k + " added")
    } catch {
        Log-Error ("Label " + $k) $_.Exception.Message
    }
}

# owner editable fields
$ownerFields = @{
    Name  = @{Reg="OwnerName"; Y=300}
    Email = @{Reg="OwnerEmail"; Y=335}
    Phone = @{Reg="OwnerPhone"; Y=370}
}
foreach ($f in $ownerFields.Keys) {
    try {
        $d = $ownerFields[$f]
        $lbl = New-Object System.Windows.Forms.Label
        $lbl.Text = $f
        $lbl.ForeColor = [System.Drawing.Color]::White
        $lbl.Location = New-Object System.Drawing.Point(50, $d.Y)
        $form.Controls.Add($lbl)

        $txt = New-Object System.Windows.Forms.TextBox
        $existing = $null
        try { $existing = (Get-ItemProperty -Path $regPath -Name $d.Reg -ErrorAction SilentlyContinue).$($d.Reg) } catch {}
        if ($existing) { $txt.Text = $existing }
        $txt.Size = New-Object System.Drawing.Size(320,24)
        $txt.Location = New-Object System.Drawing.Point(130, $d.Y - 3)

        # capture for closure
        $capReg = $regPath; $capName = $d.Reg
        $txt.Add_Leave({ try { Set-ItemProperty -Path $capReg -Name $capName -Value $txt.Text -Force } catch { Log-Error "RegistrySave" $_.Exception.Message } })
        $form.Controls.Add($txt)
        Set-Variable -Name ($f + "TextBox") -Value $txt -Scope Global
        Log-Prep ("Owner field " + $f + " added")
    } catch {
        Log-Error ("Owner field " + $f) $_.Exception.Message
    }
}

# buttons (main + toggles)
try {
    $btnMain = New-Object System.Windows.Forms.Button
    $btnMain.Text = $ButtonText
    $btnMain.Size = New-Object System.Drawing.Size(140,38)
    $btnMain.Location = New-Object System.Drawing.Point(210,560)
    $btnMain.BackColor = [System.Drawing.Color]::LightSkyBlue
    $btnMain.Add_Click({ $form.Close() })
    $form.Controls.Add($btnMain)
    Log-Prep "Main button added"
} catch { Log-Error "Main button" $_.Exception.Message }

# System toggle
try {
    $sysBtn = New-Object System.Windows.Forms.Button
    $sysBtn.Text = "System Specs"
    $sysBtn.Size = New-Object System.Drawing.Size(110,30)
    $sysBtn.Location = New-Object System.Drawing.Point(20,700)
    $sysBtn.BackColor = [System.Drawing.Color]::IndianRed
    $sysBtn.Add_Click({
        try {
            if ($null -ne $global:SystemLabel) { $global:SystemLabel.Visible = -not $global:SystemLabel.Visible }
            if ($null -ne $global:SystemIcon)  { $global:SystemIcon.Visible  = -not $global:SystemIcon.Visible  }
        } catch { Log-Error "SysToggle" $_.Exception.Message }
    })
    $form.Controls.Add($sysBtn)
    Log-Prep "System toggle added"
} catch { Log-Error "Sys toggle" $_.Exception.Message }

# License toggle
try {
    $licBtn = New-Object System.Windows.Forms.Button
    $licBtn.Text = "License"
    $licBtn.Size = New-Object System.Drawing.Size(110,30)
    $licBtn.Location = New-Object System.Drawing.Point(420,700)
    $licBtn.BackColor = [System.Drawing.Color]::SeaGreen
    $licBtn.Add_Click({
        try {
            if ($null -ne $global:LicenseLabel) { $global:LicenseLabel.Visible = -not $global:LicenseLabel.Visible }
            if ($null -ne $global:LicenseIcon)  { $global:LicenseIcon.Visible  = -not $global:LicenseIcon.Visible  }
        } catch { Log-Error "LicenseToggle" $_.Exception.Message }
    })
    $form.Controls.Add($licBtn)
    Log-Prep "License toggle added"
} catch { Log-Error "Lic toggle" $_.Exception.Message }

# finalize
try {
    $form.ResumeLayout()
    Log-Prep "Showing form"
    [void]$form.ShowDialog()
    Log-Prep "GUI closed"
} catch {
    Log-Error "ShowDialog" $_.Exception.Message
}
