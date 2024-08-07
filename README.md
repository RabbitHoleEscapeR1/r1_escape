# R1 Escape!

Tired of being locked out of the full potential of your brand new AI companion that's really just Android with a Flutter App?

Well, look no further!

The following collection of scripts will do the following:

 1. Enable "OEM Unlocking"
 2. Unlock the bootloader (will wipe any and all userdata!)
 3. Disable AVB
 4. Flash a userdebug system image of AOSP-13 (with GMS!)
 5. Rabbit Hole escaped!

## Prerequisites
### Linux
You probably need to do nothing, except have a Linux machine with root access (sudo).
If you're using a custom kernel, make sure `cdc_acm` module is present and loaded.
Please note, currently only amd64/x86_64 systems are supported. It will not work on ARM PCs.

*(If you do manage to get it working using box64, I'd be happy to merge it!)*

**The script currently supports Arch, Debian and Fedora distros.**

### Windows
You will need adb/fastboot drivers, you can grab them straight from Google, XDA or use Koush's driver package:
- **Google**: https://developer.android.com/studio/run/win-usb
- **XDA**: https://xdaforums.com/t/official-tool-windows-adb-fastboot-and-drivers-15-seconds-adb-installer-v1-4-3.2588979/
- **Koush**: https://adb.clockworkmod.com

XDA and Koush's all-in-one package is possibly a bit dated, but will do the job.

You will also require MediaTek Preloader USB VCOM drivers. Now, there are many sources on rather shady websites, but I suggest grabbing them from an OEM's instructions directly, for example:
 - **Hovatek**: https://www.hovatek.com/forum/thread-16640.html
 - **Teracube**: https://downloads.myteracube.com/Drivers/MediaTek_Preloader_USB_VCOM_Drivers_Setup_Signed.zip 
 - **Some random Mediafire source that worked for me**: https://www.mediafire.com/file/uoko5a2gnn8vwtc/MT65XX-Preloader-drivers.rar

Windows might also automatically try downloading and installing these drivers, but your mileage may vary.

## Process
Okay, lets get down to business.
### Windows
1. Open an admin PowerShell
2. Run `Set-ExecutionPolicy unrestricted`
3. Search for "Manage app execution aliases", scroll down till you see 2 entries called "App Installer" - python/python3.exe, disable these.
4. Either clone this repository or download it as ZIP
5. Extract it, and in the directory you should see a bunch of files including `r1.ps1`
6. Download and place the system.img file from here.
7. Right click in the directory and click "Open in Terminal"
8. Run `.\r1.ps1`
9. You may be asked to turn off and plug in your device multiple times, the script _should_ take care of the rest.

### Linux
1. Either clone this repository or download it as ZIP
2. Open a terminal in the directory of extracted files
3. Run `./r1.sh`
4. The script may ask you for your sudo permissions several times, so please enter your password
5. You may be asked to turn off and plug in your device, the script _should_ take care of the rest.

## Troubleshooting
### Windows
If the script stalls at any point, please check `devmgmt.msc` - Device Manager, and select the appropriate driver.
If the script says "Plug in USB" or similar, you may need to select any "Preloader USB VCOM" driver
If the script says "Waiting for device" or similar, you may need to select any "fastboot" driver.

### Linux
¯\\\_(ツ)\_/¯

### The R1 itself
Upon booting, you may be spammed with notifications saying "Your device isn't certified". This is currently normal, and you can workaround this by following here:
https://www.google.com/android/uncertified

## Restore Stock
(Thanks to [@jadentha](https://github.com/jadentha) and [@Davis8483](https://github.com/Davis8483)!)

1. Download and unzip a r1 [backup](https://drive.proton.me/urls/RWFQD4W9Z0#0xrCC1B5fq1u).

2. Run mtkclient from the command line using:

   On Windows: `python mtk wl "path\to\backup" --serialport`

   On Linux: `python mtk.py wl "path\to\backup"` (or use mtkclient-GUI).

    _(If you have issues with slow write speeds, follow this [issue](https://github.com/bkerler/mtkclient/issues/271#issuecomment-2272411904))._

3. Sit back and relax as your r1 is reset back to stock. This could take 20 minutes up to a few hours.


## Credits
- [mtkclient](https://github.com/bkerler/mtkclient/)
- my cat mocha for moral support
- Everyone else actively developing & reversing MediaTek platforms


