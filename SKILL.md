# apk-tester

Run-test Android APKs on a local virtual device and return a PASS/FAIL report backed by screenshots and logcat evidence.

## When to use

Use this skill when a user supplies an APK and asks whether it runs, crashes, or passes a known flow such as Muse Number 3's three-slot isolation check.

## Prerequisites

1. Read `config/tester.config.json` for all paths, names, and timeouts.
2. Run `setup/verify-setup.sh` before a test. If it fails, stop and report a setup/environment error (exit 2). Do not improvise an installation.
3. The Android SDK/emulator setup is the one owner-approved download. Write or inspect setup files freely, but run `setup/install-sdk.sh` only after the repository owner explicitly approves that download.
4. Use only the configured AVD. Do not use a physical phone, USB debugging, or a cloud device farm.

## The routine

1. Run `scripts/test-apk.sh <apk-path> [flow.json]`; omit the flow to use `default_flow`.
2. Confirm the APK exists, the config parses, adb and the configured AVD are available, and record package/version/SHA-256.
3. Boot the configured AVD only if it was not already running; clear logcat and install the APK.
4. Launch the app and save numbered screenshots using `scripts/launch-and-capture.sh` and `scripts/capture-screen.sh`.
5. Execute the JSON flow using `scripts/walk-flows.sh`. Stop on the first failed assertion or unsupported action.
6. Check logcat using `scripts/logcat-check.sh`; preserve the verdict and evidence file.
7. Fill `templates/test-report.md`, save a timestamped report under the configured report directory, then call `scripts/cleanup.sh`.
8. Return the report path, screenshot set, logcat evidence, and exit-code verdict.

## PASS and FAIL rules

Report PASS only when the APK installed, launched, every flow step completed, at least one screenshot exists, and logcat is non-empty with no fatal/crash match. Any failed install, launch, assertion, missing screenshot, or crash evidence is FAIL (exit 1). A malformed flow, unavailable SDK/AVD, or other setup/environment problem is exit 2 and is not a test result.

## Evidence rule

Never report a result without attaching or naming the screenshot set and the logcat verdict/evidence. “It worked” without that proof is a failed test. A silent/empty logcat is suspicious and FAIL, not CLEAN.

## Configuration rule

All SDK paths, AVD names, emulator ports, system images, timeouts, and output directories come from `config/tester.config.json`. Never hardcode an alternate path or device name in a script. APKs, reports, screenshots, SDK files, and AVD data are not committed.
