#!/bin/bash
set -euo pipefail
DIR=/usr/local/mt7902
EXPECTED=6.12.54-01180-gb4e10020ba49-dirty
if [ "$(id -u)" -ne 0 ]; then echo "Run as root" >&2; exit 1; fi
if [ -e "$DIR/disable-autoload" ]; then echo "Driver loading disabled"; exit 0; fi
if [ "$(uname -r)" != "$EXPECTED" ]; then
  echo "Kernel mismatch: $(uname -r), expected $EXPECTED" >&2
  exit 1
fi
loaded() { grep -q "^$1 " /proc/modules; }
load() {
  if loaded "$1"; then echo "$1 already loaded"
  else
    [ -f "$DIR/$2" ] || { echo "Missing $DIR/$2" >&2; exit 1; }
    insmod "$DIR/$2"
    echo "$1 loaded"
  fi
}
modprobe mac80211
load mt76 mt76.ko
load mt76_connac_lib mt76-connac-lib.ko
load mt792x_lib mt792x-lib.ko
load mt7921_common mt7921-common.ko
load mt7921e mt7921e.ko
echo "MT7902 driver loading completed"
