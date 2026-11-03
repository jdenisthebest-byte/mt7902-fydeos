# MT7902 Wi-Fi on FydeOS 23.1

A community-tested guide for getting **MediaTek MT7902 (PCI ID 14c3:7902)** Wi-Fi working on a specific FydeOS setup.

> **Experimental.** Tested on one laptop only. This repository does not include the patched driver source, compiled kernel modules or firmware. Do not use modules built for a different kernel.

## Tested setup

| Component | Value |
|---|---|
| Laptop | Acer Aspire A315-24P |
| CPU | AMD Ryzen 3 7320U |
| OS | FydeOS 23.1, amd64-fydeos_apu |
| Kernel | `6.12.54-01180-gb4e10020ba49-dirty` |
| Wi-Fi | MediaTek MT7902, `14c3:7902` |
| Kernel source commit | `b4e10020ba49ded48a0e34144c5eb2fbc813cc2b` |

**Verified:** Driver bound to PCI device, created `wlan0`, connected to a 5 GHz Wi-Fi network, and pinged 1.1.1.1 successfully. Other machines, kernels, suspend/resume and Bluetooth are not verified.

## Start here

1. Read [the beginner installation guide](docs/START-HERE.md).
2. If you already built **five matching** kernel modules, use the [safe loader](scripts/load.sh).
3. If you need to compile them, read [build notes](docs/BUILD.md).
4. Only after manual testing, consider [optional autoload](docs/AUTOLOAD.md).

## Why this worked

- Matched the running ChromiumOS kernel source and exported `/proc/config.gz`.
- Built the complete kernel to generate `Module.symvers`.
- Matched the host's Clang CFI configuration.
- Loaded `mac80211` **before** the five experimental `mt76` modules.
- Used a version-guarded loader and optional Upstart service.

## Safety and source status

This is a **guide**, not a fully reproducible driver release. The exact final patches from the successful local driver workspace have not been published. Don't download random `.ko` files or use `insmod -f`. Disabling FydeOS rootfs verification weakens security and is not required for manual testing.

Credit to the ChromiumOS kernel project and community MT7902 work including [abdullaabdullazade/mt7902_driver](https://github.com/abdullaabdullazade/mt7902_driver). Third-party code and firmware have their own licenses.
