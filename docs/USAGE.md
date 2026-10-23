# Running a test

## Command

Pass an APK and optionally a flow JSON. Omitting the flow uses `default_flow` from `config/tester.config.json`.

```bash
scripts/test-apk.sh path/to/app.apk path/to/flow.json
scripts/test-apk.sh path/to/app.apk
```

## What happens

The runner checks the APK/config/SDK/AVD, records APK identity, starts the AVD only if needed, clears logcat, installs the APK, launches and captures screens, walks the selected flow, checks logcat, writes the report, and cleans up the tested app. A setup/environment error stops the test with exit 2.

## Outputs

The configured defaults are `output/reports/` and `output/screenshots/`. Each run uses a timestamped screenshot subdirectory and timestamped report filename; a logcat evidence file is saved beside its report. These generated files are ignored by Git.

## Read the verdict

- **Exit 0 — PASS:** install and launch succeeded, every flow step passed, screenshots exist, and non-empty logcat has no crash marker.
- **Exit 1 — FAIL:** app/install/flow/assertion/logcat/evidence failure. Read the report and logcat evidence; do not treat empty logcat as clean.
- **Exit 2 — setup/environment error:** the test did not complete. Fix configuration, SDK, AVD, or malformed flow, then rerun; do not report an app verdict.

Always attach the screenshot set and name the logcat verdict when sharing results.

## Write a flow

Use `examples/muse-number-three.flow.json` for the JSON structure and `templates/flow-checklist.md` to plan coverage. v1 supports `launch`, `wait`, `tap`, `swipe`, `key`, `type`, `screenshot`, `assert_foreground`, and `assert_text`. Never place real credentials in a flow, and never include purchase, send, post, or delete actions. A flow requesting an unsupported action is rejected.

## Muse Number 3 example

After the owner-approved Android setup, test an actual APK for package `com.fedos.musenumberthree`:

```bash
scripts/test-apk.sh /path/to/muse-number-three-debug.apk examples/muse-number-three.flow.json
```

The example walks 16 steps: opens the app, captures three slots while swiping, switches back, presses Back, and checks the foreground package. It does **not** automatically prove the three accounts remain isolated. A human/agent must review real screenshots of separately authenticated test accounts side by side; do not use real user credentials or claim this check passed without that evidence.
