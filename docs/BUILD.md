# Build notes for the tested FydeOS kernel

These notes describe the **successful local experiment**, but the exact final driver patches are **not available in this repository**. A fresh source clone may not build or work without them.

1. On the FydeOS host, export the real kernel config: `zcat /proc/config.gz > fyde.config`.
2. In a Debian Penguin container, use ChromiumOS kernel source branch `chromeos-6.12` at commit `b4e10020ba49ded48a0e34144c5eb2fbc813cc2b`.
3. Copy the exported config to `.config`; run `make LLVM=-21 olddefconfig`.
4. Build the kernel using `make -j2 LLVM=-21 vmlinux modules` to generate `Module.symvers`. The successful build produced 19,570 symbol lines.
5. The tested running kernel had `# CONFIG_CFI_CLANG is not set`. An earlier mismatch caused incorrect module layout despite matching vermagic.
6. Build the **matching patched** out-of-tree mt76 driver with the same LLVM toolchain and kernel tree.
7. Confirm `modinfo -F vermagic` matches, then stage all five modules together.

The source workspace in the successful build was `~/mt7902-new/src/mt76`; that is a local path, **not** a public repository containing the final patches.

**Do not force-load incompatible modules.** The tested card was `14c3:7902`. Firmware was already present on the tested FydeOS installation under `/lib/firmware/mediatek/`. Firmware files are not bundled.
