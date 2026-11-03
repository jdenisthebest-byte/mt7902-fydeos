# Start here — install MT7902 Wi-Fi

**Who is this for?** Someone using FydeOS 23.1 with a MediaTek MT7902 card and the **exact tested kernel**. You must **already have the five compiled driver files**. They are not currently downloadable from this GitHub repository.

## Before you begin

- Save your work and back up important files. Experimental kernel drivers can crash the system.
- Make sure you have another way to access the internet or recovery instructions if Wi-Fi stops working.
- These instructions use the **FydeOS host shell**, not the Penguin/Linux container.

## Step 1 — Open the FydeOS host shell

1. Press **Ctrl + Alt + T** in FydeOS.
2. Type `shell` and press Enter. If it says the command isn't available, your FydeOS setup may not have host shell access. **Stop here** rather than trying random workarounds.
3. Check your system:

```bash
uname -r
lspci -nn | grep -i '14c3:7902'
```

You must see `6.12.54-01180-gb4e10020ba49-dirty` and the `14c3:7902` Wi-Fi device. If not, **don't install these modules**.

## Step 2 — Get the files ready

Put **all five matching driver files** in one folder:

```text
mt76.ko
mt76-connac-lib.ko
mt792x-lib.ko
mt7921-common.ko
mt7921e.ko
```

For example, use the FydeOS Downloads folder at `/home/chronos/user/MyFiles/Downloads/mt7902-modules/`.

Download this GitHub repository using **Code → Download ZIP**, extract it into Downloads, and find `scripts/install.sh` and `scripts/load.sh` inside the extracted project folder.

**Don't use driver files from a random website.** The binaries need to match the running kernel's configuration and ABI, not just its version text.

## Step 3 — Run the installer

From the **FydeOS host shell**, switch to root using your normal administrator method (for example `sudo -i` where available). Then change to the folder where you extracted this repository. For example:

```bash
cd /home/chronos/user/MyFiles/Downloads/mt7902-fydeos-main
bash scripts/install.sh /home/chronos/user/MyFiles/Downloads/mt7902-modules
```

The installer checks the kernel, PCI device, file names and module version, then copies the files into `/usr/local/mt7902`. **It doesn't activate Wi-Fi yet.**

If you see **Unsupported kernel**, **MT7902 not detected** or **Wrong vermagic**, stop and read [the troubleshooting guide](PROBLEMS-AND-FIXES.md). Do not bypass those checks.

## Step 4 — Turn on the driver

```bash
bash /usr/local/mt7902/load.sh
```

Expected last line: `MT7902 driver loading completed`. This means loading finished, **not necessarily that Wi-Fi works**.

## Step 5 — Test Wi-Fi

```bash
iw dev
lspci -nnk
```

Look for `wlan0` and `Kernel driver in use: mt7921e`. Connect using the normal FydeOS Wi-Fi menu. Then:

```bash
iw dev wlan0 link
ping -c 4 1.1.1.1
```

If you see **Connected** and receive ping replies, Wi-Fi is working. If not, use [Problems and fixes](PROBLEMS-AND-FIXES.md).

## Step 6 — Optional: start after reboot

**Manual loading does not automatically survive a reboot.** Read [Auto-start](AUTOLOAD.md). This step can require changing FydeOS's protected root filesystem, which reduces security. You can skip it and load manually when needed.

## Want to build instead?

See [Build from source](BUILD-FROM-SOURCE.md). The exact patched source is still missing from this repository, so it is not yet a guaranteed beginner build.
