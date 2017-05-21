#!/bin/bash
PATH_CMD="$(readlink -f $0)"
FIRMWARE="$(readlink -f $1)"

if [ ! -f "$FIRMWARE" ]; then
  echo "AsusWrt Mod Kit - A tool for rebuilding the firmware image of Asus ARM routers."
  echo
  echo "Usage: ./asuswrt-extract.sh <trx-image>"
  echo
  exit 1
fi

set -e
set -x

if [ -z "$(which binwalk)" ]; then
  echo "Please install binwalk."
  exit 1
fi

if [ -z "$(which xxd)" ]; then
  echo "Please install xxd."
  exit 1
fi

if [ -z "$(which make)" ]; then
  echo "Please install make."
  exit 1
fi

BUILD_NAME=$(printf "$(xxd -s -60 -g 1 -l 12 $FIRMWARE | cut -d':' -f2 | head --bytes=36 | sed 's/ /\\x/g')")
KERNEL_VER=$(printf "%d.%d" 0x$(xxd -s -64 -l 1 -ps $FIRMWARE) 0x$(xxd -s -63 -l 1 -ps $FIRMWARE))
FS_VER=$(printf "%d.%d" 0x$(xxd -s -62 -l 1 -ps $FIRMWARE) 0x$(xxd -s -61 -l 1 -ps $FIRMWARE))
SERIALNO=$(printf "%d" 0x$(xxd -s -31 -l 1 -ps $FIRMWARE)$(xxd -s -32 -l 1 -ps $FIRMWARE))
EXTENDNO=$(printf "%d" 0x$(xxd -s -29 -l 1 -ps $FIRMWARE)$(xxd -s -30 -l 1 -ps $FIRMWARE))

ROUTER_MODEL="$(echo $BUILD_NAME | tr [:upper:] [:lower:])"
case $ROUTER_MODEL in
  "rt-ac56u" )
    FILENAME_ZIP="GPL_RT_AC56U_30043807378.zip"
    FILENAME_TGZ="GPL_RT-AC56U_3.0.0.4.380.7378-g7a25649.tgz"
    ASUS_SOURCE_URL="http://dlcdnet.asus.com/pub/ASUS/wireless/RT-AC56U/$FILENAME_ZIP"
    ASUSWRT="asuswrt-rt-ac56u"
    SDK="src-rt-6.x.4708"
    ;;
  "rt-ac68u" )
    FILENAME_ZIP="GPL_RT_AC68U_30043807378.zip"
    FILENAME_TGZ="GPL_RT-AC68U_3.0.0.4.380.7378-g7a25649.tgz"
    ASUS_SOURCE_URL="http://dlcdnet.asus.com/pub/ASUS/wireless/RT-AC68U/$FILENAME_ZIP"
    ASUSWRT="asuswrt-rt-ac68u"
    SDK="src-rt-6.x.4708"
    ;;
  "rt-ac87u" )
    FILENAME_ZIP="GPL_RT_AC87U_30043807378.zip"
    FILENAME_TGZ="GPL_RT-AC87U_3.0.0.4.380.7378-g7a25649.tgz"
    ASUS_SOURCE_URL="http://dlcdnet.asus.com/pub/ASUS/wireless/RT-AC87U/$FILENAME_ZIP"
    ASUSWRT="asuswrt-rt-ac87u"
    SDK="src-rt-6.x.4708"
    ;;
  "rt-ac88u" )
    FILENAME_ZIP="GPL_RT_AC88U_30043807378.zip"
    FILENAME_TGZ="GPL_RT-AC88U_3.0.0.4.380.7378-g7a25649.tgz"
    ASUS_SOURCE_URL="http://dlcdnet.asus.com/pub/ASUS/wireless/RT-AC88U/$FILENAME_ZIP"
    ASUSWRT="asuswrt-rt-ac88u"
    SDK="src-rt-7.14.114.x/src"
    ;;
  "rt-ac3100" )
    FILENAME_ZIP="GPL_RT_AC3100_30043807378.zip"
    FILENAME_TGZ="GPL_RT-AC3100_3.0.0.4.380.7378-g7a25649.tgz"
    ASUS_SOURCE_URL="http://dlcdnet.asus.com/pub/ASUS/wireless/RT-AC3100/$FILENAME_ZIP"
    ASUSWRT="asuswrt-rt-ac3100"
    SDK="src-rt-7.14.114.x/src"
    ;;
  "rt-ac5300" )
    FILENAME_ZIP="GPL_RT_AC5300_30043807378.zip"
    FILENAME_TGZ="GPL_RT-AC5300_3.0.0.4.380.7378-g7a25649.tgz"
    ASUS_SOURCE_URL="http://dlcdnet.asus.com/pub/ASUS/wireless/RT-AC5300/$FILENAME_ZIP"
    ASUSWRT="asuswrt-rt-ac5300"
    SDK="src-rt-7.14.114.x/src"
    ;;
  "rt-ac3200" )
    FILENAME_ZIP="GPL_RT_AC3200_30043807378.zip"
    FILENAME_TGZ="GPL_RT-AC3200_3.0.0.4.380.7378-g7a25649.tgz"
    ASUS_SOURCE_URL="http://dlcdnet.asus.com/pub/ASUS/wireless/RT-AC3200/$FILENAME_ZIP"
    ASUSWRT="asuswrt-rt-ac3200"
    SDK="src-rt-7.x.main/src"
    ;;
  * )
    echo "Firmware image not supported."
    exit 1
    ;;
esac

ROOTDIR="${PATH_CMD%/*}"
SDKDIR="$ROOTDIR/$ASUSWRT/release/$SDK"
IMAGEDIR="$ROOTDIR/$ASUSWRT/release/src/router/arm-uclibc"
TARGETDIR="$IMAGEDIR/target"

mkdir -p "$ROOTDIR"
cd "$ROOTDIR"

if [ ! -f "$FILENAME_TGZ" ]; then
  [ ! -f "$FILENAME_ZIP" ] && wget $ASUS_SOURCE_URL
  unzip $FILENAME_ZIP
fi

rm -rf "$ASUSWRT"

if [ ! -d "$ASUSWRT" ]; then
  rm -rf asuswrt
  tar xzvf "$FILENAME_TGZ"
  mv asuswrt "$ASUSWRT"
  #find "$SDKDIR/linux/linux-2.6/*" -type d -exec rm -rf '{}' \; || echo "Purging some source files."
  #find $ASUSWRT/release/src/router/* -type d -exec rm -rf '{}' \; || echo "Purging some source files."
fi

set +x
echo
echo "#######################################################################################"
echo FIRMWARE="${FIRMWARE##*/}"
echo BUILD_NAME="$BUILD_NAME" 
echo KERNEL_VER="$KERNEL_VER" 
echo FS_VER="$FS_VER" 
echo SERIALNO="$SERIALNO" 
echo EXTENDNO="$EXTENDNO"
echo "#######################################################################################"
sleep 2
set -x

if [ ! -d "$TARGETDIR" ]; then
  rm -rf _*
  binwalk -e "$FIRMWARE"
  mkdir -p "$IMAGEDIR"
  mv -f _*/squashfs-root "$TARGETDIR"
  mv -f _*/1C "$IMAGEDIR/piggy"
  rm -rf _*
fi

REBUILD_FIRMWARE="$IMAGEDIR/asuswrt-rebuild.sh"
rm -rf "$REBUILD_FIRMWARE"
cat <<-EOF >"$REBUILD_FIRMWARE"
	#!/bin/bash
	set -e
	set -x
	FIRMWARE="$FIRMWARE"
	ROUTER_MODEL="$ROUTER_MODEL"
	BUILD_NAME="$BUILD_NAME"
	KERNEL_VER="$KERNEL_VER"
	FS_VER="$FS_VER"
	SERIALNO="$SERIALNO"
	EXTENDNO="$EXTENDNO"
	ROOTDIR="$ROOTDIR"
	SDKDIR="$SDKDIR"
	TARGETDIR="$TARGETDIR"
	IMAGEDIR="$IMAGEDIR"
	cd "\$SDKDIR"
	[ ! -f ctools/objcopy.original ] && mv -f ctools/objcopy ctools/objcopy.original
	echo '#!/bin/bash' >ctools/objcopy
	chmod a+x ctools/objcopy
	make image BUILD_NAME="\$BUILD_NAME" KERNEL_VER="\$KERNEL_VER" FS_VER="\$FS_VER" SERIALNO="\$SERIALNO" EXTENDNO="\$EXTENDNO"
	rm -f image/vmlinux image/vmlinux.o
	if [ -f "\${SDKDIR}/image/\${BUILD_NAME}.trx" ]; then
	  mkdir -p "\$ROOTDIR/image"
	  cd "\$ROOTDIR/image"
	  FW_NAME="\${FIRMWARE##*/}"
	  rm -rf "\$FW_NAME"
	  #ln -sf "\${SDKDIR}/image/\${BUILD_NAME}.trx" "\${FW_NAME}"
	  cp -p "\${SDKDIR}/image/\${BUILD_NAME}.trx" "\${FW_NAME}"
	  set +x
	  echo
	  echo "# ORIGINAL FIRMWARE ##################################################"
	  binwalk "\${FIRMWARE}"
	  echo "# MODIFIED FIRMWARE ##################################################"
	  binwalk "./\${FW_NAME}"
	  echo BUILD_NAME="\$BUILD_NAME" KERNEL_VER="\$KERNEL_VER" FS_VER="\$FS_VER" SERIALNO="\$SERIALNO" EXTENDNO="\$EXTENDNO"
	  echo "New firmware image was copied to: \$ROOTDIR/image"
	fi
	EOF

chmod a+x "$REBUILD_FIRMWARE"

cd "$SDKDIR"
rm -rf .config
make $ROUTER_MODEL &
sleep 7
killall make
sleep 1

rm -rf image
mkdir -p image

set +x
echo "#######################################################################################"
echo
echo "Please ignore any previous error if it says 'Terminated'.  We needed to"
echo "run a Makefile for a moment to setup the current router config."
echo
echo "Your firmware was extracted into the following directory:"
echo "  $TARGETDIR"
echo 
echo "Run the following script when you are ready to rebuild the firmware:"
echo "  $REBUILD_FIRMWARE"
echo
echo "Your new firmware image will be put in this directory:"
echo "  $ROOTDIR/image"
echo
echo "#######################################################################################"
echo

