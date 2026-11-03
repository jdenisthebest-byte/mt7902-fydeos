# Build the MT7902 driver yourself

**Reproducibility warning:** We have the working compiled modules, but **not yet the exact final patched driver source snapshot** in this repository. These steps reproduce the kernel preparation and external build approach. A fresh community driver checkout may need additional patches. Do not claim this is a guaranteed one-command build.

## Requirements

- FydeOS 23.1 with the **exact** kernel `6.12.54-01180-gb4e10020ba49-dirty`.
- MT7902 `14c3:7902`.
- Debian Penguin with Git, Make, Clang 21, LLD 21, LLVM 21, flex, bison, bc, libelf-dev, libssl-dev and other ChromiumOS kernel build dependencies.
- Enough disk space and time to compile a kernel and its modules.

## Step 1: On FydeOS host

```bash
uname -r
lspci -nn | grep -i '14c3:7902'
zcat /proc/config.gz > /home/chronos/user/MyFiles/Downloads/fyde.config
```

## Step 2: In Penguin

```bash
git clone --branch chromeos-6.12 \
  https://chromium.googlesource.com/chromiumos/third_party/kernel \
  "$HOME/fyde-kernel"
cd "$HOME/fyde-kernel"
git checkout b4e10020ba49ded48a0e34144c5eb2fbc813cc2b
cp /mnt/chromeos/MyFiles/Downloads/fyde.config .config
make LLVM=-21 olddefconfig
make -s LLVM=-21 kernelrelease
make -j2 LLVM=-21 vmlinux modules
test -s Module.symvers
```

The kernel release must match `uname -r` on the host. On the tested host `CONFIG_CFI_CLANG` was **not** enabled. Do not change it just to match this guide on a different kernel.

## Step 3: Get the driver source

Community work explored included:
- https://github.com/abdullaabdullazade/mt7902_driver

The successful build used a locally patched tree at `~/mt7902-new/src/mt76`. **That is a local folder, not a public download.** You need the corresponding source and kernel 6.12 compatibility patches. Until these are published, this section is incomplete.

With the matching source tree:
```bash
cd ~/mt7902-new/src/mt76
make KDIR="$HOME/fyde-kernel" \
  KVER=6.12.54-01180-gb4e10020ba49-dirty \
  LLVM=-21 -j2 clean
make KDIR="$HOME/fyde-kernel" \
  KVER=6.12.54-01180-gb4e10020ba49-dirty \
  LLVM=-21 -j2 modules
```

Expected files:
```text
mt76.ko
mt76-connac-lib.ko
mt792x-lib.ko
mt7921/mt7921-common.ko
mt7921/mt7921e.ko
```

Copy them to FydeOS and test using the [loader](../scripts/load.sh). The loader does not force incompatible modules.

## Step 4: Verify

```bash
modinfo mt7921/mt7921e.ko | grep -Ei '7902|vermagic'
```

Matching `vermagic` alone **cannot guarantee ABI compatibility**. Keep kernel source, config, symbols and compiler consistent.

## Firmware

The tested FydeOS installation already had `WIFI_MT7902_patch_mcu_1_1_hdr.bin.xz` and `WIFI_RAM_CODE_MT7902_1.bin.xz` under `/lib/firmware/mediatek`. No firmware is included in this repository. Check firmware license terms before redistribution.
