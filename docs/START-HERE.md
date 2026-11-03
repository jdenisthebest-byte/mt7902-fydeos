# Beginner guide: start here

**Before you start:** This guide is for the **exact** tested FydeOS kernel, and requires **five compiled driver files**. The repository does **not** provide those files yet. There is no working one-click installation for new users until the exact patched source or tested builds are published.

## Step 1: Check your laptop

Open FydeOS terminal, enter `shell`, then:

```bash
uname -r
lspci -nn | grep -i '14c3:7902'
```

The tested kernel is `6.12.54-01180-gb4e10020ba49-dirty`. If your kernel differs, **stop**: these scripts are not built for it.

## Step 2: Put your compiled modules in one folder

You need:

```text
mt76.ko
mt76-connac-lib.ko
mt792x-lib.ko
mt7921-common.ko
mt7921e.ko
```

They must have been compiled for your running kernel, configuration and symbol table. See [BUILD.md](BUILD.md) for the observed build process and its limitations.

## Step 3: Stage and load

As root on the FydeOS **host**, copy the five files and `scripts/load.sh` to `/usr/local/mt7902/`. Then:

```bash
bash /usr/local/mt7902/load.sh
```

**Save your work before loading an experimental driver.** A kernel crash is possible.

## Step 4: Check if it works

```bash
lspci -nnk
iw dev wlan0 link
ip -4 addr show wlan0
ping -c 4 1.1.1.1
```

If Wi-Fi appears but cannot connect, check `initctl status shill` and `dmesg | grep -Ei 'mt7921e|firmware|timeout|reset' | tail -40`.

## Step 5: Make it load at boot (optional)

Read [AUTOLOAD.md](AUTOLOAD.md) carefully. **Do not** disable rootfs verification just to try the driver for the first time.

## Need help?

Open a GitHub issue with your FydeOS version, kernel release, PCI ID and **redacted** error logs. Never share passwords, Wi-Fi names or MAC addresses.
