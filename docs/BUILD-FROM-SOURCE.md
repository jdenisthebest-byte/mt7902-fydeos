# Build MT7902 drivers yourself — beginner walkthrough

**Current limitation:** The exact final **patched driver source** that produced our five working `.ko` files has **not yet been uploaded**. You can reproduce the **kernel preparation** below, but the last driver-build step cannot be guaranteed until that source is published.

## What are we building?

FydeOS needs a driver compiled for **your exact running Linux kernel**. The kernel source supplies headers and symbol information. The experimental MT7902 source supplies the actual Wi-Fi driver. These are **two different things**.

### Step 1 — Check your FydeOS version (FydeOS host shell)

Press **Ctrl + Alt + T**, type `shell`, then:

```bash
uname -r
lspci -nn | grep -i '14c3:7902'
```

Our tested release is `6.12.54-01180-gb4e10020ba49-dirty`. **Stop if yours is different**; the source commit below is specifically for our kernel.

### Step 2 — Save the exact kernel settings (FydeOS host shell)

```bash
zcat /proc/config.gz > /home/chronos/user/MyFiles/Downloads/fyde.config
```

This creates `fyde.config` in Downloads. The kernel configuration is important: using a generic one previously caused our module to fail.

### Step 3 — Open Penguin/Linux Terminal

Use the **Linux Terminal app** inside FydeOS. These build commands run in the **Penguin container**, not the FydeOS host shell.

First see if tools are available:

```bash
git --version
make --version
clang-21 --version
ld.lld-21 --version
```

If missing, install the needed build tools from your Debian repositories. An example for a Debian version that provides LLVM 21 packages is:

```bash
sudo apt update
sudo apt install git make clang-21 lld-21 llvm-21 flex bison bc libelf-dev libssl-dev dwarves
```

**Note:** Some Debian versions don't provide LLVM 21 directly. If `apt` says `Unable to locate package`, stop and install a supported LLVM 21 toolchain from a trusted repository appropriate to your container. Don't silently switch compiler versions and assume the modules will match.

### Step 4 — Download the matching ChromiumOS kernel

In Penguin:

```bash
git clone --branch chromeos-6.12 \
  https://chromium.googlesource.com/chromiumos/third_party/kernel \
  "$HOME/fyde-kernel"

cd "$HOME/fyde-kernel"
git checkout b4e10020ba49ded48a0e34144c5eb2fbc813cc2b
```

This download is large and can take time.

### Step 5 — Copy your FydeOS config into the source

```bash
cp /mnt/chromeos/MyFiles/Downloads/fyde.config .config
make LLVM=-21 olddefconfig
make -s LLVM=-21 kernelrelease
```

**Check:** The final command must print exactly:

```text
6.12.54-01180-gb4e10020ba49-dirty
```

If it doesn't, **stop**. A different kernel release means the driver may not load.

### Step 6 — Generate the kernel symbol table

```bash
make -j2 LLVM=-21 vmlinux modules
test -s Module.symvers && echo "Module.symvers is ready"
```

This is a long build. The last command should print `Module.symvers is ready`. In our test, skipping this caused many `modpost unresolved symbol` errors.

### Step 7 — Check the CFI setting

On the FydeOS host:

```bash
zcat /proc/config.gz | grep CONFIG_CFI_CLANG
```

In Penguin:

```bash
grep CONFIG_CFI_CLANG ~/fyde-kernel/.config
```

The settings should match. For **our tested kernel**, CFI was disabled. A mismatch caused modules to appear loaded without initializing properly.

### Step 8 — Compile the MT7902 driver

**This step needs the exact patched source tree**, which is not currently included in this GitHub project. The successful build used a local workspace at `~/mt7902-new/src/mt76`. A community starting point was [abdullaabdullazade/mt7902_driver](https://github.com/abdullaabdullazade/mt7902_driver), but a fresh clone is **not guaranteed to build or work**.

Once the matching source tree is available, the tested commands were:

```bash
cd ~/mt7902-new/src/mt76

make KDIR="$HOME/fyde-kernel" \
  KVER=6.12.54-01180-gb4e10020ba49-dirty \
  LLVM=-21 -j2 clean

make KDIR="$HOME/fyde-kernel" \
  KVER=6.12.54-01180-gb4e10020ba49-dirty \
  LLVM=-21 -j2 modules
```

### Step 9 — Find the finished files

Look for these five modules:

```text
mt76.ko
mt76-connac-lib.ko
mt792x-lib.ko
mt7921/mt7921-common.ko
mt7921/mt7921e.ko
```

Move copies into one folder and use [START HERE](START-HERE.md) to install them. **Do not overwrite stock system driver files**.

### Common errors

| Error | What to read |
| --- | --- |
| `ld.lld not found` | [Problem 2](PROBLEMS-AND-FIXES.md#problem-2--ldlld-command-not-found-while-building) |
| `Module.symvers missing` | [Problem 3](PROBLEMS-AND-FIXES.md#problem-3--modpost-unresolved-symbols--missing-modulesymvers) |
| Driver loads but no Wi-Fi | [Problem 4](PROBLEMS-AND-FIXES.md#problem-4--driver-is-in-lsmod-but-wi-fi-still-doesnt-appear) |
| `Unknown symbol ieee80211_*` | [Problem 5](PROBLEMS-AND-FIXES.md#problem-5--unknown-symbol-ieee80211_-when-loading-mt76ko) |

**Do not publish an unverified build as a working driver.** The remaining task for a fully reproducible project is to recover and publish the exact patched source and its license notices.
