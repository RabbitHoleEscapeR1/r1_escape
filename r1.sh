#!/bin/bash

install_debian() {
    sudo apt update
    [[ -x "$(command -v git)" ]] || sudo apt install -y git
    [[ -x "$(command -v python3)" ]] || sudo apt install -y python3
    [[ -x "$(command -v pip3)" ]] || sudo apt install -y python3-pip
    [[ -x "$(command -v dos2unix)" ]] || sudo apt install -y dos2unix
    [[ -x "$(command -v curl)" ]] || sudo apt install -y curl
    [[ -x "$(command -v unzip)" ]] || sudo apt install -y unzip
}

install_arch() {
    sudo pacman -Sy --noconfirm
    [[ -x "$(command -v git)" ]] || sudo pacman -S --noconfirm git
    [[ -x "$(command -v python3)" ]] || sudo pacman -S --noconfirm python
    [[ -x "$(command -v dos2unix)" ]] || sudo pacman -S --noconfirm dos2unix
    [[ -x "$(command -v curl)" ]] || sudo pacman -S --noconfirm curl
    [[ -x "$(command -v unzip)" ]] || sudo pacman -S --noconfirm unzip
    [[ -x "$(command -v virtualenv)" ]] || sudo pacman -S --noconfirm python-virtualenv
}

install_fedora() {
    sudo dnf update -y
    [[ -x "$(command -v git)" ]] || sudo dnf install -y git
    [[ -x "$(command -v python3)" ]] || sudo dnf install -y python3
    [[ -x "$(command -v pip3)" ]] || sudo dnf install -y python3-pip
    [[ -x "$(command -v dos2unix)" ]] || sudo dnf install -y dos2unix
    [[ -x "$(command -v curl)" ]] || sudo dnf install -y curl
    [[ -x "$(command -v unzip)" ]] || sudo dnf install -y unzip
}

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v apt-get &>/dev/null; then
        install_debian
    elif command -v pacman &>/dev/null; then
        install_arch
    elif command -v dnf &>/dev/null; then
        install_fedora
    else
        echo "Unsupported Linux distribution"
        exit 1
    fi
else
    echo "Unsupported OS"
    exit 1
fi

if [[ "$OSTYPE" != "linux-gnu"* || ! "$(command -v pacman)" ]]; then
    pip3 show virtualenv &>/dev/null || pip3 install virtualenv
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v apt-get &>/dev/null; then
        sudo apt install -y adb fastboot
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm android-tools
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y android-tools
    fi
fi

SP_FLASH_TOOL_URL_LINUX="https://spflashtools.com/wp-content/uploads/SP_Flash_Tool_v5.2228_Linux.zip"
SP_FLASH_TOOL_DIR="SP_Flash_Tool"
SP_FLASH_TOOL_FLAG="sp_flash_tool_extracted"

if [[ ! -f "$SP_FLASH_TOOL_FLAG" ]]; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        curl -o sp_flash_tool.zip "$SP_FLASH_TOOL_URL_LINUX"
        mkdir -p "$SP_FLASH_TOOL_DIR"
        unzip -o sp_flash_tool.zip "SP_Flash_Tool_v5.2228_Linux/*" -d "$SP_FLASH_TOOL_DIR"
        mv "$SP_FLASH_TOOL_DIR/SP_Flash_Tool_v5.2228_Linux"/* "$SP_FLASH_TOOL_DIR"
        rm -rf "$SP_FLASH_TOOL_DIR/SP_Flash_Tool_v5.2228_Linux"
        rm sp_flash_tool.zip
    fi
    cp *.xml "$SP_FLASH_TOOL_DIR/"
    touch "$SP_FLASH_TOOL_FLAG"
fi

FLASH_TOOL_CMD="sudo ./flash_tool"

# Setup virtualenv and install requirements
python3 -m venv venv
source venv/bin/activate
pip install pyserial

chmod +x mtkbootcmd.py

cd SP_Flash_Tool/
chmod +x ./flash_tool
chmod +x ./flash_tool.sh

read -p "Power off the device, press ENTER, and then plug the device in."
$FLASH_TOOL_CMD -i read_frp.xml -b

sudo chown $USER frp.bin

LAST_BYTE=$(xxd -p -l 1 -s -1 frp.bin)
if [[ "$LAST_BYTE" == "00" ]]; then
    printf '\x01' | dd of=frp.bin bs=1 seek=$(($(stat -c%s frp.bin) - 1)) conv=notrunc
fi

$FLASH_TOOL_CMD -i write_frp.xml -b

cd ..

sudo ./mtkbootcmd.py FASTBOOT

# Wait for a device to show up under "fastboot devices"
while ! fastboot devices | grep -q "fastboot"; do
    echo "Waiting for fastboot..."
    sleep 1
done

#fastboot flashing unlock
#fastboot -w
#fastboot flash --disable-verity --disable-verification vbmeta vbmeta.img
#fastboot reboot-fastboot
#fastboot flash system system.img
#fastboot reboot
