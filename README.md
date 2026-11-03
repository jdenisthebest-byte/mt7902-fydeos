# MT7902 Wi-Fi for FydeOS — Beginner Guide

This project documents how we got **MediaTek MT7902 Wi-Fi working on one FydeOS laptop**.

> **Read this first:** This is an experimental driver for a **specific kernel**, not an official MediaTek or FydeOS update. The repository currently contains installation scripts and instructions, **not the five compiled .ko driver files**. The exact final patched source has not yet been published, so a fully reproducible from-scratch build is not available yet.

## 1. Can I use it?

| Check | Tested device |
| --- | --- |
| Laptop | Acer Aspire A315-24P |
| Wi-Fi chip | MediaTek MT7902, PCI ID `14c3:7902` |
| Operating system | FydeOS 23.1 (`amd64-fydeos_apu`) |
| Exact kernel | `6.12.54-01180-gb4e10020ba49-dirty` |

Open the **FydeOS host shell** (not the Linux/Penguin terminal) and run:

```bash
uname -r
lspci -nn | grep -i '14c3:7902'
```

If the kernel is different, **stop**. These compiled modules are not for your kernel. If no device appears, this guide isn't for your Wi-Fi card.

## 2. Choose what you want to do

| I want to… | Open this |
| --- | --- |
| Install five driver files I already have | **[START HERE — installation in plain English](docs/START-HERE.md)** |
| Fix an error | **[Problems and fixes, step by step](docs/PROBLEMS-AND-FIXES.md)** |
| Build drivers myself | **[Build tutorial](docs/BUILD-FROM-SOURCE.md)** |
| Make Wi-Fi load when I turn on my laptop | **[Optional auto-start guide](docs/AUTOLOAD.md)** |
| Check whether my driver files match | [Driver binary information](docs/BINARY-FILES.md) |

## 3. What does the installer actually do?

The [installer script](scripts/install.sh) **copies five driver files you already have** into `/usr/local/mt7902`. It checks the kernel version, Wi-Fi PCI ID and module version first. It does **not** download drivers, disable root filesystem verification or change boot settings.

The [loader script](scripts/load.sh) loads the required modules in the correct order. It does **not** promise compatibility on another system.

## 4. What worked in our test?

The driver attached to the MT7902, created `wlan0`, connected to a 5 GHz Wi-Fi network and passed an internet ping test. We also got the modules loading after reboot using a custom Upstart service. This has **not** been independently verified on other devices.

## 5. Need help?

Open a GitHub issue and tell us: your FydeOS version, output of `uname -r`, whether the MT7902 appears in `lspci`, and the exact error message. **Remove Wi-Fi network names, MAC addresses and personal information from logs.**

**Credits:** ChromiumOS kernel maintainers and community MT7902 driver projects, including [abdullaabdullazade/mt7902_driver](https://github.com/abdullaabdullazade/mt7902_driver). No proprietary firmware is bundled. Don't redistribute driver binaries without checking applicable source and license obligations.
