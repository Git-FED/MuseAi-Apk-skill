# MuseAi-Skill-apk-testing

Muse tests the APK itself—on a virtual phone, with screenshots as proof.

APK Tester Skill runs an Android APK on a configured Android Virtual Device (AVD), walks a JSON-defined flow, checks logcat, and produces a fixed-shape PASS/FAIL report. It does not require a physical phone.

## The test routine

1. Check the configured SDK and AVD.
2. Identify the APK and record its SHA-256.
3. Boot the virtual phone if needed and install the APK.
4. Launch it and capture screens as evidence.
5. Walk the requested flow and check logcat for crashes.
6. Save a report, screenshots, and logcat evidence, then clean up.

## Two parts

- **One-time setup:** install the Android command-line tools, emulator, and configured system image, create the AVD, then verify it. The setup scripts are provided but have not been run. Run them only with the repository owner's approval for the Android SDK download.
- **Every test:** run the test command with an APK and an optional flow file.

## Quick start

After the owner-approved setup is complete:

```bash
setup/verify-setup.sh
scripts/test-apk.sh path/to/app.apk examples/muse-number-three.flow.json
```

Use the default flow by omitting the second argument:

```bash
scripts/test-apk.sh path/to/app.apk
```

## What counts as proof

A result needs screenshots **and** a logcat verdict. PASS requires a successful install and launch, all flow steps completed, screenshots captured, and no fatal exception. Reports and screenshots are generated under the configured `output/` directories and are ignored by Git; they are not committed.

## Repository map

- `SKILL.md` — agent instructions and verdict rules.
- `config/` — single source for SDK, AVD, timeout, and output settings.
- `setup/` — owner-approved SDK installation, AVD creation, and verification scripts.
- `scripts/` — APK test, capture, flow, logcat, and cleanup routines.
- `examples/` and `templates/` — example flow and fixed report/checklist formats.
- `docs/` — setup, usage, decisions, troubleshooting, deployment, and full file-tree contract.
- `prompts/` — standalone generation prompts and build contract.
- `assets/` and `index.html` — landing-page art and page.

## Website hosting

The GitHub repository is the source of truth. The static landing page is prepared for Cloudflare Pages Git integration, with a small `dist/` copy step that publishes only `index.html` and `assets/`. See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) for the Cloudflare Pages settings and the optional Workers path. The favicon and image URLs stay relative so they work from both root domains and GitHub Pages project paths.

## Safety and support

Never commit an APK under test, reports, screenshots, SDK files, or AVD data. Generic navigation uses gestures only; flow files must never buy, send, post, or delete. Setup failures are exit 2, test failures exit 1, and PASS exits 0.

Support: [museai@fedpromptly.com](mailto:museai@fedpromptly.com).
