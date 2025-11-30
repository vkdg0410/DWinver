# DWinver.ps1 — Fixed & hardened version (system-specs safe, resource loader, registry, step logs)
# Replace your existing DWinver.ps1 with this file.

# ==============================
# Step Counter Setup
# ==============================
$totalSteps = 30
$currentStep = 0
function Log-Prep([string]$name) {
    $global:currentStep++
    # Time prefix helps spotting where things hang
    $time = (Get-Date).ToString("HH:mm:ss")
    Write-Host ("[{0}] Step {1}/{2}: Prepared {3}" -f $time, $global:currentStep, $totalSteps, $name)
}

function Log-Error([string]$name, [string]$msg) {
    $time = (Get-Date).ToString("HH:mm:ss")
    Write-Host ("[{0}] ERROR during {1}: {2}" -f $time, $name, $msg)
}

# ==============================
# 2) Gather System Specs (simple + debugger safe)
# ==============================
try {
    $osObj  = Get-WmiObject -Class Win32_OperatingSystem -ErrorAction SilentlyContinue
    $cpuObj = Get-WmiObject -Class Win32_Processor        -ErrorAction SilentlyContinue
    $csObj  = Get-WmiObject -Class Win32_ComputerSystem   -ErrorAction SilentlyContinue

    $OS  = if ($osObj.Caption) { $osObj.Caption } else { "Unknown OS" }
    $CPU = if ($cpuObj.Name)   { $cpuObj.Name }   else { "Unknown CPU" }
    $RAM = if ($csObj.TotalPhysicalMemory) {
        "{0:N2} GB" -f ($csObj.TotalPhysicalMemory / 1GB)
    } else { "Unknown RAM" }

    Log-Prep "System Specs Gathered"
} catch {
    Log-Error "System Specs" $_.Exception.Message
    $OS="Unknown OS"; $CPU="Unknown CPU"; $RAM="Unknown RAM"
}

# ==============================
# BEGIN Initialization
# ==============================
$DWinver_Load = { }

# 1) Load WinForms + Drawing
try {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    Log-Prep "GUI Assembly Types Loaded"
} catch {
    Log-Error "GUI Assembly Types Load" $_.Exception.Message
}

# 2) Gather System Specs (safe, non-blocking)
try {
    $OS = "Unknown OS"
    $CPU = "Unknown CPU"
    $RAM = "Unknown RAM"

    $osObj = Safe-GetCim -ClassName "Win32_OperatingSystem" -TimeoutSeconds 4
    if ($osObj -ne $null) {
        # Get-CimInstance returns a collection — pick first relevant
        if ($osObj -is [System.Array]) { $osObj = $osObj[0] }
        if ($osObj -and $osObj.Caption) { $OS = $osObj.Caption }
    } else {
        Log-Prep "Get-CimInstance Win32_OperatingSystem timed out or returned nothing"
    }

    $cpuObj = Safe-GetCim -ClassName "Win32_Processor" -TimeoutSeconds 4
    if ($cpuObj -ne $null) {
        if ($cpuObj -is [System.Array]) { $cpuObj = $cpuObj[0] }
        if ($cpuObj -and $cpuObj.Name) { $CPU = $cpuObj.Name }
    } else {
        Log-Prep "Get-CimInstance Win32_Processor timed out or returned nothing"
    }

    $csObj = Safe-GetCim -ClassName "Win32_ComputerSystem" -TimeoutSeconds 4
    if ($csObj -ne $null) {
        if ($csObj -is [System.Array]) { $csObj = $csObj[0] }
        if ($csObj -and $csObj.TotalPhysicalMemory) {
            $RAM = "{0:N2} GB" -f ($csObj.TotalPhysicalMemory / 1GB)
        }
    } else {
        Log-Prep "Get-CimInstance Win32_ComputerSystem timed out or returned nothing"
    }

    Log-Prep "System Specs Gathered"
} catch {
    Log-Error "System Specs" $_.Exception.Message
}
#TSWIWTCWC

#This
#Section
#Makes
#Me
#Wanna
#Commit
#War
#Crimes

#When I have to debug this cuz it doesn't work, the Geneva suggestions flash before my eyes and I actually wanna pste them in right here!

# 3) Software metadata
try {
    $AppName      = "D" + $OS
    $Version      = "DWinVer 2.0"
    $Company      = "Dev Setup"
    $Author       = "Dev0630"
    $ReleaseDate  = "October 1, 2024"
    $Description  = "Fish"
    $Copyright    = "© Copyright Dev Setup All Rats reserved!"
    $ButtonText   = "I Rat it!"
    Log-Prep "Software Info Initialized"
} catch {
    Log-Error "Software Info Init" $_.Exception.Message
}

# 4) Owner/support info
try {
    $ComputerName = $env:COMPUTERNAME
    $License      = "Product keys will come out in V-3.0!"
    $SupportName    = "Vagvolgyi-Krucso David Gabor"
    $SupportCompany = "Dev Setup"
    $SupportEmail   = "vkdg0410@gmail.com"
    $SupportPhone   = "+36204927891"
    Log-Prep "Support and Owner Info Initialized"
} catch {
    Log-Error "Owner/Support Init" $_.Exception.Message
}

# 5) Registry path (ensure exists)
try {
    $regPath = "HKCU:\Software\DWinver"
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    Log-Prep "Registry Path Initialized"
} catch {
    Log-Error "Registry Setup" $_.Exception.Message
}

# 6) Resource loader (from Resources\ folder)
function Get-Resource([string]$name) {
    $candidates = @(
        Join-Path $PSScriptRoot "Resources\$name.ico",
        Join-Path $PSScriptRoot "Resources\$name.png",
        Join-Path $PSScriptRoot "Resources\$name.jpg"
    )
    foreach ($path in $candidates) {
        if (Test-Path $path) {
            try {
                $ext = [System.IO.Path]::GetExtension($path).ToLowerInvariant()
                if ($ext -eq ".ico") {
                    # ICO -> Icon object -> ToBitmap for PictureBox.Image
                    try {
                        $icon = New-Object System.Drawing.Icon($path)
                        return $icon.ToBitmap()
                    } catch {
                        return [System.Drawing.Image]::FromFile($path)
                    }
                } else {
                    return [System.Drawing.Image]::FromFile($path)
                }
            } catch {
                Log-Error ("Resource load for $path") $_.Exception.Message
                return $null
            }
        }
    }
    # not found
    return $null
}
Log-Prep "Resource Loader Ready"

# 7) Create main form
try {
    $form = New-Object Windows.Forms.Form
    $form.Text = "About DWindows"
    $form.Size = New-Object Drawing.Size(550,750)
    $form.StartPosition = "CenterScreen"
    $form.BackColor = [System.Drawing.Color]::MediumPurple
    $form.SuspendLayout()
    Log-Prep "Main Form Created"
} catch {
    Log-Error "Form Creation" $_.Exception.Message
}

# 8) Title
try {
    $titleLabel = New-Object Windows.Forms.Label
    $titleLabel.Text = "About DWindows"
    $titleLabel.ForeColor = [System.Drawing.Color]::White
    $titleLabel.Font = New-Object Drawing.Font("Segoe UI",18,[Drawing.FontStyle]::Bold)
    $titleLabel.AutoSize = $true
    $titleLabel.Location = New-Object Drawing.Point(150,20)
    $form.Controls.Add($titleLabel)
    Log-Prep "Title Label Added"
} catch {
    Log-Error "Title Label" $_.Exception.Message
}

# 9-13) PictureBoxes (icons)
$resources = @{
    ProgramIcon = @{Point=[Drawing.Point]::new(20,80); Resource="programdata"}
    OwnerIcon   = @{Point=[Drawing.Point]::new(20,230); Resource="owner"}
    SupportIcon = @{Point=[Drawing.Point]::new(20,400); Resource="support"}
    SystemIcon  = @{Point=[Drawing.Point]::new(20,510); Resource="systeminfo"; Visible=$false}
    LicenseIcon = @{Point=[Drawing.Point]::new(20,560); Resource="license"; Visible=$false}
}

foreach ($key in $resources.Keys) {
    try {
        $pic = New-Object Windows.Forms.PictureBox
        $pic.SizeMode = 'AutoSize'
        $pic.Location = $resources[$key].Point
        $img = Get-Resource $resources[$key].Resource
        if ($img -ne $null) { $pic.Image = $img } else { 
            # optional: use a simple placeholder bitmap when missing
            $bmp = New-Object System.Drawing.Bitmap 32,32
            $g = [System.Drawing.Graphics]::FromImage($bmp)
            $g.Clear([System.Drawing.Color]::Transparent)
            $g.Dispose()
            $pic.Image = $bmp
        }
        if ($resources[$key].ContainsKey("Visible")) { $pic.Visible = $resources[$key].Visible }
        $form.Controls.Add($pic)
        Set-Variable -Name $key -Value $pic -Scope Global
        Log-Prep ("PictureBox " + $key + " Added")
    } catch {
        Log-Error ("PictureBox " + $key) $_.Exception.Message
    }
}

# 14-18) Labels
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

foreach ($key in $labels.Keys) {
    try {
        $lbl = New-Object Windows.Forms.Label
        $lbl.Text = $labels[$key].Text
        $lbl.ForeColor = [System.Drawing.Color]::White
        $lbl.Font = New-Object Drawing.Font("Segoe UI",12,[Drawing.FontStyle]::Bold)
        $lbl.AutoSize = $true
        $lbl.Location = $labels[$key].Point
        if ($labels[$key].ContainsKey("Visible")) { $lbl.Visible = $labels[$key].Visible }
        $form.Controls.Add($lbl)
        Set-Variable -Name ($key + "Label") -Value $lbl -Scope Global
        Log-Prep ("Label " + $key + " Added")
    } catch {
        Log-Error ("Label " + $key) $_.Exception.Message
    }
}

# 19-24) Owner editable fields (Label + TextBox each)
$ownerFields = @{
    Name  = @{Registry="OwnerName"; Y=300}
    Email = @{Registry="OwnerEmail"; Y=335}
    Phone = @{Registry="OwnerPhone"; Y=370}
}

foreach ($field in $ownerFields.Keys) {
    try {
        # Label
        $lbl = New-Object Windows.Forms.Label
        $lbl.Text = $field
        $lbl.ForeColor = [System.Drawing.Color]::White
        $lbl.Font = New-Object Drawing.Font("Segoe UI",12,[Drawing.FontStyle]::Bold)
        $lbl.AutoSize = $true
        $lbl.Location = New-Object Drawing.Point(50, $ownerFields[$field].Y)
        $form.Controls.Add($lbl)
        Log-Prep ("Owner Label " + $field + " Added")

        # TextBox
        $txt = New-Object Windows.Forms.TextBox
        $existing = $null
        try {
            $existing = (Get-ItemProperty -Path $regPath -Name $ownerFields[$field].Registry -ErrorAction SilentlyContinue).$($ownerFields[$field].Registry)
        } catch { $existing = $null }
        if ($existing) { $txt.Text = $existing }

        $txt.Font = New-Object Drawing.Font("Segoe UI",12)
        $txt.Size = New-Object Drawing.Size(300,25)
        $txt.Location = New-Object Drawing.Point(150,$ownerFields[$field].Y)

        # Create closures safely by capturing current values
        $captureReg = $regPath
        $captureName = $ownerFields[$field].Registry
        $txt.Add_Leave({
            try {
                Set-ItemProperty -Path $captureReg -Name $captureName -Value $txt.Text -Force
            } catch {
                Write-Host ("Failed saving {0} to registry: {1}" -f $captureName, $_.Exception.Message)
            }
        })
        $form.Controls.Add($txt)
        Set-Variable -Name ($field + "TextBox") -Value $txt -Scope Global
        Log-Prep ("Owner TextBox " + $field + " Added")
    } catch {
        Log-Error ("Owner Field " + $field) $_.Exception.Message
    }
}

# 25) Main button
try {
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
    Log-Prep "Main Button Added"
} catch {
    Log-Error "Main Button" $_.Exception.Message
}

# 26) System Specs toggle
try {
    $sysBtn = New-Object Windows.Forms.Button
    $sysBtn.Text = "System Specs"
    $sysBtn.Size = New-Object Drawing.Size(120,35)
    $sysBtn.Location = New-Object Drawing.Point(20,635)
    $sysBtn.BackColor = [System.Drawing.Color]::Red
    $sysBtn.Add_Click({
        try {
            $newState = -not $SystemLabel.Visible
            $SystemLabel.Visible = $newState
            $SystemIcon.Visible = $newState
        } catch {
            Write-Host "Toggle system specs failed: $_"
        }
    })
    $form.Controls.Add($sysBtn)
    Log-Prep "System Toggle Button Added"
} catch {
    Log-Error "System Toggle Button" $_.Exception.Message
}

# 27) License toggle
try {
    $licBtn = New-Object Windows.Forms.Button
    $licBtn.Text = "License"
    $licBtn.Size = New-Object Drawing.Size(120,35)
    $licBtn.Location = New-Object Drawing.Point(400,635)
    $licBtn.BackColor = [System.Drawing.Color]::Green
    $licBtn.Add_Click({
        try {
            $newState = -not $LicenseLabel.Visible
            $LicenseLabel.Visible = $newState
            $LicenseIcon.Visible = $newState
        } catch {
            Write-Host "Toggle license failed: $_"
        }
    })
    $form.Controls.Add($licBtn)
    Log-Prep "License Toggle Button Added"
} catch {
    Log-Error "License Toggle Button" $_.Exception.Message
}

# Finish layout and show form
try {
    $form.ResumeLayout()
    [void]$form.ShowDialog()
    Log-Prep "GUI Displayed - Everything Loaded"
} catch {
    Log-Error "GUI Display" $_.Exception.Message
}
