#!/bin/bash
# Safe installer for ALREADY-BUILT modules for the exact tested kernel.
# Does not disable rootfs verification, modify /etc/init, or force-load modules.
set -euo pipefail
EXPECTED="6.12.54-01180-gb4e10020ba49-dirty"
DEST="/usr/local/mt7902"
SOURCE_DIR="${1:-}"
FILES=(mt76.ko mt76-connac-lib.ko mt792x-lib.ko mt7921-common.ko mt7921e.ko)
if [ "$(id -u)" -ne 0 ]; then echo "Run as root" >&2; exit 1; fi
if [ "$(uname -r)" != "$EXPECTED" ]; then
  echo "Unsupported kernel: $(uname -r). Tested: $EXPECTED" >&2; exit 1
fi
if [ -z "$SOURCE_DIR" ] || [ ! -d "$SOURCE_DIR" ]; then
  echo "Usage: bash scripts/install.sh /folder/containing/five-ko-files" >&2; exit 1
fi
for file in "${FILES[@]}"; do
  [ -f "$SOURCE_DIR/$file" ] || { echo "Missing $file" >&2; exit 1; }
  magic="$(modinfo -F vermagic "$SOURCE_DIR/$file")"
  case "$magic" in "$EXPECTED "*) ;; *) echo "Wrong vermagic for $file: $magic" >&2; exit 1;; esac
done
if ! lspci -nn | grep -qi '14c3:7902'; then
  echo "MT7902 PCI ID 14c3:7902 not detected. Aborting." >&2; exit 1
fi
mkdir -p "$DEST"
for file in "${FILES[@]}"; do install -m 0644 "$SOURCE_DIR/$file" "$DEST/$file"; done
install -m 0755 "$(dirname "$0")/load.sh" "$DEST/load.sh"
echo "Installed five modules into $DEST"
echo "Next: bash $DEST/load.sh"
echo "Optional boot service: read docs/AUTOLOAD.md first"
