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

$SP_FLASH_TOOL_URL_WIN = "https://spflashtools.com/wp-content/uploads/SP_Flash_Tool_v5.2316_Win.zip"
$SP_FLASH_TOOL_DIR = "SP_Flash_Tool"
$SP_FLASH_TOOL_FLAG = "sp_flash_tool_extracted"

if (-not (Test-Path $SP_FLASH_TOOL_FLAG)) {
    Invoke-WebRequest -Uri $SP_FLASH_TOOL_URL_WIN -OutFile "sp_flash_tool.zip"
    New-Item -ItemType Directory -Path $SP_FLASH_TOOL_DIR -ErrorAction SilentlyContinue | Out-Null
    Expand-Archive -Path "sp_flash_tool.zip" -DestinationPath $SP_FLASH_TOOL_DIR -Force
    Move-Item -Path "$($SP_FLASH_TOOL_DIR)\SP_Flash_Tool_v5.2316_Win\*" -Destination $SP_FLASH_TOOL_DIR -Force
    Remove-Item -Path "$($SP_FLASH_TOOL_DIR)\SP_Flash_Tool_v5.2316_Win" -Recurse -Force
    Remove-Item -Path "sp_flash_tool.zip" -Force
    Copy-Item *.xml $SP_FLASH_TOOL_DIR
    New-Item -Path $SP_FLASH_TOOL_FLAG -ItemType File -Force
}

python -m venv venv
.\venv\Scripts\Activate.ps1
pip install pyserial

Set-Location -Path $SP_FLASH_TOOL_DIR

Read-Host "Power off the device, press ENTER, and then plug the device in."

Start-Process -Wait -FilePath .\flash_tool.exe -ArgumentList "-i read_frp.xml -b"

$frpBinPath = "frp.bin"
$frpBinBytes = [System.IO.File]::ReadAllBytes($frpBinPath)

if ($frpBinBytes[-1] -eq 0x00) {
    $frpBinBytes[-1] = 0x01
    [System.IO.File]::WriteAllBytes($frpBinPath, $frpBinBytes)
}

Start-Process -Wait -FilePath .\flash_tool.exe -ArgumentList "-i write_frp.xml -b"

Set-Location -Path $PSScriptRoot

Start-Process -Wait -FilePath python -ArgumentList "mtkbootcmd.py FASTBOOT"

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
