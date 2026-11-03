# MT7902 problems and fixes — step by step

These are the problems we actually encountered while getting MT7902 Wi-Fi working on **FydeOS 23.1, kernel `6.12.54-01180-gb4e10020ba49-dirty`**.

**First:** Open the FydeOS host shell with **Ctrl + Alt + T → `shell`**. Use a root shell for commands that need administrator privileges. **Never force-load a module** to bypass a compatibility error.

## Problem 1 — FydeOS doesn't show my Wi-Fi card

**What you see:** No Wi-Fi network interface, even though the laptop has an MT7902.

**Step 1.** Find the Wi-Fi hardware:

```bash
lspci -nnk | grep -A4 -i '14c3:7902'
```

**Step 2.** If nothing appears, your PCI device may not be MT7902 or may not be detected. This driver guide is not the fix; check your hardware first.

**Step 3.** If you see `14c3:7902`, check the running kernel:

```bash
uname -r
```

**Step 4.** If it matches the tested kernel and you have five **matching** modules, follow [START HERE](START-HERE.md) to install and load them.

**Step 5.** Verify:

```bash
iw dev
lspci -nnk | grep -A4 -i '14c3:7902'
```

**Success looks like:** `wlan0` appears and `Kernel driver in use: mt7921e` is shown. You still need to connect to a network to verify full operation.

## Problem 2 — `ld.lld: command not found` while building

**Why it happened:** The compiler/linker tools weren't installed in the Penguin container.

**Step 1.** Open **Linux Terminal (Penguin)**, not the FydeOS host shell.

**Step 2.** Check whether the required LLVM tools exist:

```bash
command -v clang-21
command -v ld.lld-21
command -v make
```

**Step 3.** If a command prints nothing, install the corresponding toolchain using the Debian package manager. Package names and repositories depend on your Penguin version; see [the build tutorial](BUILD-FROM-SOURCE.md). Don't assume the default `clang` is version 21.

**Step 4.** Run the kernel build with the versioned tools:

```bash
make LLVM=-21 olddefconfig
```

**Success looks like:** No `ld.lld not found` error. This doesn't mean the whole driver is built yet.

## Problem 3 — `modpost: unresolved symbols` / missing `Module.symvers`

**What you see:** Errors mentioning `__fentry__`, `_raw_spin_lock_irqsave`, `usleep_range` or a warning about `Module.symvers`.

**Why it happened:** We originally ran `modules_prepare` but didn't have the full symbol export table.

**Step 1.** In Penguin, go to the **matching ChromiumOS kernel source** directory:

```bash
cd ~/fyde-kernel
```

**Step 2.** Make sure this source tree uses the **real FydeOS kernel configuration** exported from `/proc/config.gz` as explained in [BUILD FROM SOURCE](BUILD-FROM-SOURCE.md).

**Step 3.** Generate the missing symbol table:

```bash
make -j2 LLVM=-21 vmlinux modules
```

This can take a long time and needs disk space.

**Step 4.** Confirm the table exists:

```bash
test -s Module.symvers && echo "Symbol table exists"
```

**Step 5.** Clean and rebuild the external driver using this same kernel source. See [Build from source](BUILD-FROM-SOURCE.md).

**Success looks like:** The driver build finishes without unresolved-symbol errors. A `Module.symvers` file alone doesn't guarantee all patches are correct.

## Problem 4 — Driver is in `lsmod` but Wi-Fi still doesn't appear

**Why it happened in our build:** Our external build accidentally enabled `CONFIG_CFI_CLANG` while the running FydeOS kernel had it disabled. This changed the module's internal ABI layout.

**Step 1.** On the FydeOS **host** check the actual config:

```bash
zcat /proc/config.gz | grep CONFIG_CFI_CLANG
```

For our exact tested kernel, it said `# CONFIG_CFI_CLANG is not set`.

**Step 2.** In Penguin, check the config in your kernel source:

```bash
grep CONFIG_CFI_CLANG ~/fyde-kernel/.config
```

**Step 3.** If the two differ, stop using those compiled modules. Recreate the build configuration from the **running host's exported config**, then rebuild the matching kernel symbols and all five external modules. Follow [Build from source](BUILD-FROM-SOURCE.md).

**Step 4.** Check whether the driver is attached after a clean rebuild:

```bash
lspci -nnk | grep -A4 -i '14c3:7902'
iw dev
```

**Success looks like:** `mt7921e` is bound to the device and `wlan0` exists. **Matching `vermagic` alone does not prove ABI compatibility.**

## Problem 5 — `Unknown symbol ieee80211_*` when loading `mt76.ko`

**Why it happened:** We forgot to load the required `mac80211` kernel subsystem first.

**Step 1.** On the FydeOS host as root:

```bash
modprobe mac80211
```

**Step 2.** Check it loaded:

```bash
lsmod | grep mac80211
```

**Step 3.** Instead of inserting the five modules in a random order, run the provided loader:

```bash
bash /usr/local/mt7902/load.sh
```

It loads `mt76`, `mt76-connac-lib`, `mt792x-lib`, `mt7921-common`, then `mt7921e`.

**Step 4.** Confirm:

```bash
lsmod | grep -E 'mt76|mt792'
iw dev
```

**Success looks like:** No more `ieee80211_*` symbol errors and a detected Wi-Fi interface.

## Problem 6 — Wi-Fi works, then disappears after reboot

**Why it happened:** `insmod` loads a module for the **current boot only**.

**Step 1.** Confirm the five modules and loader are saved:

```bash
ls /usr/local/mt7902/
```

**Step 2.** Load them again manually:

```bash
bash /usr/local/mt7902/load.sh
```

**Step 3.** If that works, read the [optional auto-start guide](AUTOLOAD.md) to create an Upstart boot job.

**Step 4.** After reboot, check:

```bash
lsmod | grep mt7921e
iw dev
```

**Success looks like:** The driver loads after reboot. **Auto-start requires advanced boot changes on our FydeOS build** and may reduce device security.

## Problem 7 — Wi-Fi appears but can't connect

**Step 1.** Check whether you're actually connected:

```bash
iw dev wlan0 link
```

**Step 2.** Check if your laptop received an IP address:

```bash
ip -4 addr show wlan0
```

**Step 3.** Check the route:

```bash
ip -4 route
```

**Step 4.** Check internet access:

```bash
ping -c 4 1.1.1.1
```

**Step 5.** Check the FydeOS network service:

```bash
initctl status shill
```

If Wi-Fi is connected but there's no IP address, the problem may be DHCP/network setup, not the driver. If it isn't connected at all, check the Wi-Fi password and firmware logs. Restarting `shill` is a **diagnostic option** but temporarily disconnects networking:

```bash
initctl restart shill
```

**Success looks like:** Connected Wi-Fi, a valid IP address and ping replies.

## Problem 8 — Wi-Fi takes 5–15 seconds to connect

**What we observed:** It took about five seconds to connect on the tested laptop.

**Step 1.** Wait for the connection and run:

```bash
iw dev wlan0 link
```

**Step 2.** Check for driver resets or firmware errors:

```bash
dmesg | grep -Ei 'mt7921e|timeout|firmware|reset' | tail -40
```

**Step 3.** If it connects reliably and internet works, a five-second delay alone doesn't prove a fault. If it regularly fails or times out, include redacted logs in a GitHub issue.

**Important:** We did **not** verify a specific command that permanently fixed the five-second delay, so we won't pretend we did.

## Problem 9 — `Wrong vermagic` or `Unsupported kernel`

**Step 1.** Run:

```bash
uname -r
modinfo -F vermagic /path/to/mt7921e.ko
```

**Step 2.** Compare the kernel version at the start of `vermagic` to `uname -r`.

**Step 3.** If different, **do not force-load**. Rebuild the modules for your exact kernel using the correct configuration and source. See [Build from source](BUILD-FROM-SOURCE.md).

**Success looks like:** Matching version information **and** a driver that successfully binds and connects. A matching version alone is not enough.

---

Still stuck? [Open an issue](https://github.com/jdenisthebest-byte/mt7902-fydeos/issues) with the **problem number**, FydeOS version, kernel, PCI ID and a **redacted** error message.
