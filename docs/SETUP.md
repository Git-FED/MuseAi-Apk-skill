# One-time setup

> **Before you start:** the Android SDK/emulator download happens once and only after the repository owner explicitly approves it. Do not run setup “just to try it.” Writing these scripts is not approval to download.

## What gets installed

`setup/install-sdk.sh` downloads Google's Android command-line tools and installs platform-tools/adb, the emulator, and the system image named in `config/tester.config.json`. By default, the SDK is placed under `~/Android/Sdk`; the AVD is stored by Android tooling outside this repository. No SDK or AVD files belong in Git.

## Steps

Run these from the repository root, only after approval:

```bash
setup/install-sdk.sh
setup/create-avd.sh
setup/verify-setup.sh
```

The verification script boots the configured AVD headlessly, confirms adb can run a shell command, and shuts it down. Expected final output includes:

```text
PASS: config parses
PASS: adb version
PASS: emulator binary
PASS: configured AVD exists
PASS: emulator boot completed
PASS: adb shell works
PASS: emulator shutdown
SETUP: PASS
```

Any failed check returns exit 2. Fix setup before attempting an APK test; never report that failed setup as an app result.

## Estimates

Disk and time vary by host, Android image, and network. **Estimate:** reserve several gigabytes for the SDK/system image and additional space for the virtual device. **Estimate:** download and first boot may take several minutes or longer.

## Start over

Only if the owner requests a reset: use `avdmanager delete avd --name <configured-name>` and remove the configured SDK directory, then repeat the three steps above. Confirm the paths from `config/tester.config.json` before deleting anything; never delete unrelated AVDs or SDK installations.

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for setup failures.
