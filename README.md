# asuswrt-mod-kit

The AsusWrt Mod Kit is a tool for rebuilding the firmware image of Asus ARM routers.

This tool will automatically detect the router model and version of your firmware image, then download directly from Asus the GPL source package for your router model.  This is done to ensure a proper firmware format when you repack the image.

Binwalk is used to extract the AsusWrt filesystem and Linux kernel from the (.trx) image.

Any piece of the AsusWrt filesystem may be changed. The Linux kernel cannot be changed.  When you're finished with the filesystem, my script initiates the firmware rebuild by utilizing the original Asus firmware packaging tools.

DISCLAIMER: There is risk of damage to your router when you play with custom firmwares.  I use this tool on my RT-AC68U router without any issues.  However, no testing has been done for the other Asus ARM routers. Before using this tool, you should be familiar with the recovery methods available for unbricking a router.  


### Getting started with AsusWrt Mod Kit
```
# Tested with Ubuntu 16.04.2 LTS
sudo apt install git binwalk
cd
git clone https://github.com/blackfuel/asuswrt-mod-kit.git
cd asuswrt-mod-kit
./asuswrt-extract.sh <trx-image>
```


### How to see the firmware version info
```
# grab some firmwares from the Asus website and display the version info
wget -nc http://dlcdnet.asus.com/pub/ASUS/wireless/RT-AC68U/FW_RT_AC68U_30043807378.zip
unzip FW_RT_AC68U_30043807378.zip
./asuswrt-version.sh RT-AC68U_3.0.0.4_380_7378-g7a25649.trx
tail --bytes=256 RT-AC68U_3.0.0.4_380_7378-g7a25649.trx | hexdump -C

# an old firmware
wget -nc http://dlcdnet.asus.com/pub/ASUS/wireless/RT-AC68U/FW_RT_AC68U_3004374291.zip
unzip FW_RT_AC68U_3004374291.zip
./asuswrt-version.sh FW_RT_AC68U_3004374291.trx
tail --bytes=256 FW_RT_AC68U_3004374291.trx | hexdump -C
```
