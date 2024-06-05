# Function to install Chocolatey if not installed
function Install-Chocolatey {
    if (-not (Test-Path "$env:ProgramData\chocolatey")) {
        $InstallDir='C:\ProgramData\chocoportable'
        $env:ChocolateyInstall="$InstallDir"
        Set-ExecutionPolicy Bypass -Scope Process -Force;
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }
}

# Check if Chocolatey is installed
if (-not (Test-Path "$env:ProgramData\chocolatey")) {
    Install-Chocolatey
}

function Install-PackageIfNotInstalled {
    param (
        [string]$PackageName,
        [string]$InstallerScript
    )
    if (-not (Get-Command $PackageName -ErrorAction SilentlyContinue)) {
        Write-Output "Installing $PackageName..."
        Invoke-Expression $InstallerScript
    }
}

Install-PackageIfNotInstalled "git" "choco install git -y"
Install-PackageIfNotInstalled "python" "choco install python -y"
Install-PackageIfNotInstalled "virtualenv" "pip install virtualenv"

Install-PackageIfNotInstalled "adb" "choco install adb -y"
Install-PackageIfNotInstalled "fastboot" "choco install fastboot -y"

python -m venv venv
.\venv\Scripts\Activate.ps1

$repoUrl = "https://github.com/AgentFabulous/mtkclient"
$repoName = [System.IO.Path]::GetFileNameWithoutExtension($repoUrl)
git clone $repoUrl
Set-Location -Path $repoName
pip install -r requirements.txt

Read-Host "[*] Power off the device, press ENTER, and then plug the device in"

python mtk r frp frp.bin --serialport

$currentDir = Get-Location
$frpBinPath = Join-Path -Path $currentDir -ChildPath "frp.bin"
$frpBinBytes = [System.IO.File]::ReadAllBytes($frpBinPath)
if ($frpBinBytes[-1] -eq 0x00) {
    $frpBinBytes[-1] = 0x01
    [System.IO.File]::WriteAllBytes($frpBinPath, $frpBinBytes)
}

Read-Host "[*] Unplug the device, press ENTER, and then plug the device in"

python mtk w frp frp.bin --serialport

Set-Location -Path $PSScriptRoot

Read-Host "[*] Unplug the device, press ENTER, and then plug the device in"

Start-Process -Wait -FilePath python -ArgumentList "mtkbootcmd.py FASTBOOT"

Write-Output "[*] Waiting for fastboot..."

do {
    Start-Sleep -Seconds 1
    $fastbootDevices = fastboot devices
} while (-not $fastbootDevices)

fastboot flashing unlock
fastboot -w
fastboot flash --disable-verity --disable-verification vbmeta vbmeta.img
fastboot reboot-fastboot
fastboot flash system system.img
fastboot reboot
