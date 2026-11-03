# Optional Upstart autoload

**Advanced users only.** Test the driver manually first. Disabling FydeOS rootfs verification weakens boot security. Keep recovery media ready.

The tested machine used Upstart 1.14 and a writable `/usr/local`. Its service was installed in `/etc/init/mt7902-wifi.conf` only after rootfs verification had been disabled and the root filesystem made writable.

1. Place the five matching modules and `load.sh` in `/usr/local/mt7902/`.
2. Test `bash /usr/local/mt7902/load.sh` and confirm actual Wi-Fi traffic.
3. Before experimenting with boot services, create `touch /usr/local/mt7902/disable-autoload` to prevent loading.
4. If you **choose** to modify your protected root filesystem, read FydeOS-specific security and recovery guidance first. Copy [the example job](../upstart/mt7902-wifi.conf) into `/etc/init/mt7902-wifi.conf`.
5. Run `initctl reload-configuration` and `initctl check-config mt7902-wifi`.
6. After verifying you can recover the machine, remove `disable-autoload` and reboot to test.

To disable future automatic loads, create `/usr/local/mt7902/disable-autoload` again. It does not unload an already-running driver.

Kernel updates require new matching modules. Do not reuse old `.ko` files.
