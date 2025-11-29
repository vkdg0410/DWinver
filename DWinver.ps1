# ==============================
# Step Counter Setup
# ==============================
$totalSteps = 28
$currentStep = 0
function Log-Prep([string]$name) {
    $global:currentStep++
    Write-Host ("Step {0}/{1}: Prepared {2}" -f $global:currentStep, $totalSteps, $name)
}

$DWinver_Load = { }

# ==============================
# Load WinForms + Drawing
# ==============================
try {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    Log-Prep "GUI Assembly Types Loaded"
} catch {
    Write-Host "Step $currentStep failed: GUI Assembly Types Load Error - $_"
}

# ==============================
# Software / System Information
# ==============================
try {
    # safe CIM reads (don't assume success)
    $OS = "Unknown OS"
    $CPU = "Unknown CPU"
    $RAM = "Unknown RAM"
    try {
        $osObj = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
        if ($osObj -and $osObj.Caption) { $OS = $osObj.Caption }
    } catch {}
    try {
        $cpuObj = Get-CimInstance -ClassName Win32_Processor -ErrorAction Stop
        if ($cpuObj -and $cpuObj.Name) { $CPU = $cpuObj.Name }
    } catch {}
    try {
        $csObj = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop
        if ($csObj -and $csObj.TotalPhysicalMemory) { $RAM = "{0:N2} GB" -f ($csObj.TotalPhysicalMemory / 1GB) }
    } catch {}

    Log-Prep "System Specs Gathered"
} catch {
    Write-Host "Step $currentStep failed: System Specs Error - $_"
}

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
    Write-Host "Step $currentStep failed: Software Info Init Error - $_"
}

try {
    $ComputerName = $env:COMPUTERNAME
    $License      = "Product keys will come out in V-3.0!"
    $SupportName    = "Vagvolgyi-Krucso David Gabor"
    $SupportCompany = "Dev Setup"
    $SupportEmail   = "vkdg0410@gmail.com"
    $SupportPhone   = "+36204927891"
    Log-Prep "Support and Owner Info Initialized"
} catch {
    Write-Host "Step $currentStep failed: Owner/Support Info Init Error - $_"
}

# ==============================
# Registry Setup (ensure $regPath exists)
# ==============================
try {
    $regPath = "HKCU:\Software\DWinver"
    if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }
    Log-Prep "Registry Path Initialized"
} catch {
    Write-Host "Step $currentStep failed: Registry Setup Error - $_"
}

# ==============================
# Resource Loader (loads files from Resources\ folder)
# ==============================
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
                Write-Host ("Resource load failed for {0}: {1}" -f $path, $_.Exception.Message)
                return $null
            }
        }
    }
    Write-Host ("Resource not found for '{0}' (checked .ico/.png/.jpg in Resources\)" -f $name)
    return $null
}
Log-Prep "Resource Loader Ready"

# ==============================
# GUI Form Creation
# ==============================
try {
    $form = New-Object Windows.Forms.Form
    $form.Text = "About DWindows"
    $form.Size = New-Object Drawing.Size(550,750)
    $form.StartPosition = "CenterScreen"
    $form.BackColor = [System.Drawing.Color]::MediumPurple
    $form.SuspendLayout()
    Log-Prep "Main Form Created"
} catch {
    Write-Host "Step $currentStep failed: Form Creation Error - $_"
}

# --- Title ---
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
    Write-Host "Step $currentStep failed: Title Label Error - $_"
}

# --- Icons ---
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
        if ($img -ne $null) { $pic.Image = $img }
        if ($resources[$key].ContainsKey("Visible")) { $pic.Visible = $resources[$key].Visible }
        $form.Controls.Add($pic)
        Set-Variable -Name $key -Value $pic -Scope Global
        Log-Prep ("PictureBox " + $key + " Added")
    } catch {
        Write-Host "Step $currentStep failed: PictureBox $key Error - $_"
    }
}

# --- Labels ---
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
        Write-Host "Step $currentStep failed: Label $key Error - $_"
    }
}

# --- Owner Fields ---
$ownerFields = @{
    Name  = @{Registry="OwnerName"; Y=300}
    Email = @{Registry="OwnerEmail"; Y=335}
    Phone = @{Registry="OwnerPhone"; Y=370}
}

foreach ($field in $ownerFields.Keys) {
    try {
        $lbl = New-Object Windows.Forms.Label
        $lbl.Text = $field
        $lbl.ForeColor = [System.Drawing.Color]::White
        $lbl.Font = New-Object Drawing.Font("Segoe UI",12,[Drawing.FontStyle]::Bold)
        $lbl.AutoSize = $true
        $lbl.Location = New-Object Drawing.Point(50, $ownerFields[$field].Y)
        $form.Controls.Add($lbl)
        Log-Prep ("Owner Label " + $field + " Added")

        $txt = New-Object Windows.Forms.TextBox
        $existing = $null
        try {
            $existing = (Get-ItemProperty -Path $regPath -Name $ownerFields[$field].Registry -ErrorAction SilentlyContinue).$($ownerFields[$field].Registry)
        } catch { $existing = $null }
        if ($existing) { $txt.Text = $existing }

        $txt.Font = New-Object Drawing.Font("Segoe UI",12)
        $txt.Size = New-Object Drawing.Size(300,25)
        $txt.Location = New-Object Drawing.Point(150,$ownerFields[$field].Y)

        $reg = $regPath
        $regName = $ownerFields[$field].Registry
        $txt.Add_Leave({
            try {
                Set-ItemProperty -Path $reg -Name $regName -Value $txt.Text -Force
            } catch {
                Write-Host ("Failed saving {0} to registry: {1}" -f $regName, $_.Exception.Message)
            }
        })
        $form.Controls.Add($txt)
        Set-Variable -Name ($field + "TextBox") -Value $txt -Scope Global
        Log-Prep ("Owner TextBox " + $field + " Added")
    } catch {
        Write-Host "Step $currentStep failed: Owner Field $field Error - $_"
    }
}

# --- Buttons ---
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
    Write-Host "Step $currentStep failed: Main Button Error - $_"
}

# --- System Specs Toggle ---
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
    Write-Host "Step $currentStep failed: System Toggle Button Error - $_"
}

# --- License Toggle ---
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
    Write-Host "Step $currentStep failed: License Toggle Button Error - $_"
}

# --- Show Form ---
try {
    $form.ResumeLayout()
    [void]$form.ShowDialog()
    Log-Prep "GUI Displayed - Everything Loaded"
} catch {
    Write-Host "Step $currentStep failed: GUI Display Error - $_"
}