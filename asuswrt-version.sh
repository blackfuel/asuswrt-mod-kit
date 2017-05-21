#!/bin/bash
FIRMWARE="$1"

if [ ! -f "$FIRMWARE" ]; then
  echo "Print firmware version information"
  echo
  echo "Usage: ./asuswrt-version.sh <trx-image>"
  echo
  exit 1
fi

if [ -z "$(which xxd)" ]; then
  echo "Please install xxd."
  exit 1
fi

BUILD_NAME=$(printf "$(xxd -s -60 -g 1 -l 12 $FIRMWARE | cut -d':' -f2 | head --bytes=36 | sed 's/ /\\x/g')")
KERNEL_VER=$(printf "%d.%d" 0x$(xxd -s -64 -l 1 -ps $FIRMWARE) 0x$(xxd -s -63 -l 1 -ps $FIRMWARE))
FS_VER=$(printf "%d.%d" 0x$(xxd -s -62 -l 1 -ps $FIRMWARE) 0x$(xxd -s -61 -l 1 -ps $FIRMWARE))
SERIALNO=$(printf "%d" 0x$(xxd -s -31 -l 1 -ps $FIRMWARE)$(xxd -s -32 -l 1 -ps $FIRMWARE))
EXTENDNO=$(printf "%d" 0x$(xxd -s -29 -l 1 -ps $FIRMWARE)$(xxd -s -30 -l 1 -ps $FIRMWARE))

tail --bytes=256 $FIRMWARE | hexdump -C
echo
echo FIRMWARE="${FIRMWARE##*/}"
echo BUILD_NAME="$BUILD_NAME" 
echo KERNEL_VER="$KERNEL_VER" 
echo FS_VER="$FS_VER" 
echo SERIALNO="$SERIALNO" 
echo EXTENDNO="$EXTENDNO"

