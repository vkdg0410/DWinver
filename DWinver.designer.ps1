[void][System.Reflection.Assembly]::Load('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
[void][System.Reflection.Assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
$DWinver = New-Object -TypeName System.Windows.Forms.Form
function InitializeComponent
{
$resources = . (Join-Path $PSScriptRoot 'DWinver.resources.ps1')
$DWinver.SuspendLayout()
#
#DWinver
#
$DWinver.AccessibleName = [System.String]''
$DWinver.ClientSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]284,[System.Int32]261))
$DWinver.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$DWinver.Icon = ([System.Drawing.Icon]$resources.'$this.Icon')
$DWinver.MaximizeBox = $false
$DWinver.MinimizeBox = $false
$DWinver.Name = [System.String]'DWinver'
$DWinver.ShowInTaskbar = $false
$DWinver.Text = [System.String]'HELO! EXE IS OKE!'
$DWinver.add_Load($DWinver_Load)
$DWinver.ResumeLayout($false)
}
. InitializeComponent
