# Troubleshooting

A setup/environment failure is exit code 2. Fix the setup. Never report a test result from a run that didn't happen.

Resolve paths from `config/tester.config.json`; do not substitute another SDK or AVD.

## 1. Emulator boot timeout
**SYMPTOM:** `sys.boot_completed` did not become `1` before the configured timeout.
**CAUSE:** First boot may be slow, the AVD may be unhealthy, or host resources may be constrained.
**FIX:** Retry only after checking host capacity; inspect `emulator -avd apk-tester-phone -port 5554 -no-window -no-audio` output. Confirm the AVD name and timeout in config, then run `setup/verify-setup.sh`.

## 2. Virtualization (KVM/HAXM) unavailable
**SYMPTOM:** Emulator reports acceleration/virtualization unavailable.
**CAUSE:** Host virtualization support is disabled or unavailable to the current user.
**FIX:** On Linux, inspect `egrep -c '(vmx|svm)' /proc/cpuinfo` and `ls -l /dev/kvm`; enable virtualization in host firmware or grant the current user the host-approved KVM access, then retry verification. Do not install unrelated packages from this script.

## 3. adb device offline or unauthorized
**SYMPTOM:** `adb devices` lists the configured emulator as `offline` or `unauthorized`.
**CAUSE:** The emulator transport is not ready or stale adb state remains.
**FIX:** Run `"$(python3 -c 'import json,os;print(os.path.expanduser(json.load(open("config/tester.config.json"))["sdk_root"])+"/platform-tools/adb")' )" kill-server`; then start/verify the configured AVD with `setup/verify-setup.sh`.

## 4. Install fails (INSTALL_FAILED_* codes)
**SYMPTOM:** Install prints `INSTALL_FAILED_UPDATE_INCOMPATIBLE` or `INSTALL_FAILED_VERSION_DOWNGRADE`.
**CAUSE:** Signature differs from an installed package, or the APK version is older than the installed version.
**FIX:** The runner cleans up its tested package. If a prior copy remains, remove only the named test package with `adb uninstall <package>`; use a correctly signed build or a newer APK. Do not uninstall unrelated apps.

## 5. App launches to a black screen
**SYMPTOM:** Launch screenshot is black or the app never renders content.
**CAUSE:** App startup/network/backend issue, WebView problem, or a crash before drawing.
**FIX:** Inspect the report and `logcat-<package>.txt`; rerun only after fixing the app/environment and preserve a new evidence set.

## 6. Logcat empty
**SYMPTOM:** `LOGCAT: EMPTY (suspicious)`.
**CAUSE:** App process/log buffer was unavailable, launch failed, or package filtering found no lines.
**FIX:** Confirm launch evidence and package identity; inspect `adb logcat -d` directly. Empty output is FAIL, never CLEAN.

## 7. Screenshots black (FLAG_SECURE)
**SYMPTOM:** Screenshot is black or excludes protected content.
**CAUSE:** The app uses Android `FLAG_SECURE` or another protected-surface policy.
**FIX:** Confirm the limitation with the app owner. Disable protection only in an explicitly authorized debug build; never bypass security on a production app. Report the missing visual evidence as a limitation/failure.

## 8. AVD snapshot corrupt
**SYMPTOM:** Emulator fails while loading a snapshot or exits during startup.
**CAUSE:** A saved AVD snapshot is corrupt.
**FIX:** After confirming the configured AVD name, start it with `emulator -avd apk-tester-phone -port 5554 -no-snapshot-load -no-window -no-audio`; if it boots, shut it down cleanly and rerun verification. Do not delete an AVD without owner approval.

## 9. Emulator port 5554 busy
**SYMPTOM:** Emulator cannot bind the configured port.
**CAUSE:** Another emulator/process already owns the configured port.
**FIX:** Inspect `adb devices` and `ps -ef | grep '[e]mulator'`; leave unrelated processes untouched. Stop only the test emulator you own, or ask the owner to choose a free configured port, then rerun verification.
