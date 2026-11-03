# Make MT7902 Wi-Fi load when FydeOS starts

**Beginner warning:** This is optional and more advanced than manual installation. On our FydeOS version, saving an Upstart job under `/etc/init` required making the protected root filesystem writable. **Disabling rootfs verification weakens security** and can affect updates. Don't attempt it until manual Wi-Fi works and you have a recovery plan.

## Step 1 — Make sure the manual driver works

Open the **FydeOS host shell** as root:

```bash
bash /usr/local/mt7902/load.sh
iw dev wlan0 link
ping -c 4 1.1.1.1
```

If Wi-Fi doesn't connect, stop and follow [Problems and fixes](PROBLEMS-AND-FIXES.md). An auto-start service won't repair a broken driver.

## Step 2 — Create the emergency off switch

```bash
touch /usr/local/mt7902/disable-autoload
```

As long as this file exists, our loader refuses to load the modules. This lets you turn off automatic loading without deleting driver files.

## Step 3 — Check which startup system you have

```bash
initctl version
ls /etc/init
```

Our test used **Upstart**. If `initctl` is missing or your system is different, stop. Do not copy these steps to systemd or another boot manager.

## Step 4 — Understand the security change

On the tested FydeOS system, `/etc/init` was on a **read-only, verified** root filesystem. Installing a new boot service there required the owner to deliberately disable rootfs verification and make root writable. This is a security trade-off, **not a normal requirement for Wi-Fi drivers**.

Only continue if you understand how to restore FydeOS using official recovery media. Follow the **FydeOS instructions for your exact release** for that security change; don't copy commands from an unrelated Chromebook.

## Step 5 — Install the example startup job

Once `/etc/init` is writable, go to the extracted repository folder in the host shell and run:

```bash
cp upstart/mt7902-wifi.conf /etc/init/mt7902-wifi.conf
chmod 644 /etc/init/mt7902-wifi.conf
initctl reload-configuration
initctl check-config mt7902-wifi
```

If any command errors, stop and read the message. Do not proceed to reboot.

## Step 6 — Test safely with auto-start still disabled

```bash
initctl start mt7902-wifi
initctl status mt7902-wifi
```

Because `disable-autoload` exists, this test **does not load the driver**. The service is a one-time task, so it can finish and show `stop/waiting`.

## Step 7 — Enable it only after a recovery plan is ready

```bash
rm /usr/local/mt7902/disable-autoload
```

Reboot and check:

```bash
lsmod | grep mt7921e
iw dev
```

Then connect and test internet access. If the driver fails after reboot, re-create the disable switch from a working root shell:

```bash
touch /usr/local/mt7902/disable-autoload
```

This prevents **future** loads by the custom job; it does not unload a module already running.

## Step 8 — Undo the boot service if needed

With the root filesystem writable, disable the custom service by moving its config:

```bash
mv /etc/init/mt7902-wifi.conf /etc/init/mt7902-wifi.conf.disabled
initctl reload-configuration
```

**After any FydeOS kernel update**, check `uname -r` again. The provided loader refuses other kernel versions. Don't force old modules into a new kernel.
