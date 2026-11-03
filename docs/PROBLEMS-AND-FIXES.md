# Every major problem we hit and how we fixed it

This is the troubleshooting history from the **tested Acer Aspire A315-24P** running FydeOS 23.1, kernel `6.12.54-01180-gb4e10020ba49-dirty`.

## 1. Wi-Fi missing in FydeOS

**Symptoms:** MT7902 appeared in `lspci -nnk` as `14c3:7902` but no working Wi-Fi device.

**Cause:** The stock `mt7921e` driver did not have a matching MT7902 PCI alias / working support for this card.

**What worked:** An experimental MT7902-enabled `mt76/mt7921e` driver built for the running kernel. The successful module advertises `pci:v000014C3d00007902...` and requests MT7902 firmware.

**Check:**
```bash
lspci -nnk
modinfo /usr/local/mt7902/mt7921e.ko | grep -i 7902
```

## 2. Out-of-tree build failed with unresolved symbols

**Symptoms:** `modpost` errors such as `__fentry__`, `_raw_spin_lock_irqsave`, `__x86_indirect_thunk_r11` and `usleep_range`; warning that `Module.symvers` was missing.

**Cause:** `modules_prepare` alone does **not** generate a complete `Module.symvers` for this external module build.

**What worked:** Checkout exact ChromiumOS kernel source commit `b4e10020ba49ded48a0e34144c5eb2fbc813cc2b`, copy the running `/proc/config.gz` config, then build `vmlinux modules` with LLVM 21 to generate matching symbols.

## 3. Compiler tools missing

**Symptoms:** `make LLVM=1 olddefconfig` failed because `ld.lld` was missing.

**What worked:** Installed the matching LLVM/Clang 21 build tools in Debian Penguin and used the versioned LLVM toolchain.

## 4. Modules looked loaded but didn't initialize properly

**Symptoms:** Module appeared in `lsmod` but the expected PCI probe / interface was missing.

**Cause in the tested build:** The build config accidentally enabled `CONFIG_CFI_CLANG`, which was **disabled** in the running kernel. This changed module ABI layout. Matching `vermagic` did not catch it.

**What worked:** Rebuilt the matching kernel symbol table and all external modules with the **host's real config**. For the tested kernel, `# CONFIG_CFI_CLANG is not set`.

## 5. `Unknown symbol ieee80211_*` when inserting mt76

**Cause:** `mac80211` wasn't loaded.

**What worked:**
```bash
modprobe mac80211
```
Then load the five modules in order: `mt76`, `mt76-connac-lib`, `mt792x-lib`, `mt7921-common`, `mt7921e`.

## 6. Driver worked until reboot

**Cause:** Manually inserted modules aren't automatically loaded after restarting FydeOS.

**What worked:** Store them under `/usr/local/mt7902` and use the optional Upstart service in `upstart/mt7902-wifi.conf`. See [AUTOLOAD.md](AUTOLOAD.md) for security implications and the disable switch.

## 7. Wi-Fi takes around 5 seconds to connect

**Observation:** Wi-Fi connected, but connection establishment took roughly 5 seconds.

**Status:** No confirmed driver defect or fix. Five seconds can reflect scanning, authentication, DHCP or network-manager timing. Don't claim it was fixed by a command without measurements.

**Diagnose:**
```bash
iw dev wlan0 link
ip -4 addr show wlan0
ip -4 route
initctl status shill
dmesg | grep -Ei 'mt7921e|timeout|firmware|reset' | tail -40
```

## Important

These were **observed fixes on one machine**. They aren't proof of compatibility with all MT7902 laptops, FydeOS versions, or kernels. Redact SSIDs, MAC addresses and private details from logs before posting issues.
