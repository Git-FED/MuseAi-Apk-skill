# Binding decisions

Changes require the repository owner's order and must be recorded in `CHANGELOG.md`.

## D1 — Spec-only boundary and one approved download
**Rule:** Do not install or run setup from the spec alone. The Android SDK/emulator download is the one owner-approved download; no other downloads or installs are allowed by these scripts.
**Why:** The owner controls machine changes and network downloads.

## D2 — Proof, never claims
**Rule:** Every test report needs screenshots and a logcat verdict. PASS requires install, launch, clean non-empty logcat, and every flow step.
**Why:** A result must be independently reviewable.

## D3 — Virtual phone only
**Rule:** v1 uses one configured local AVD; no physical phone, USB debugging, or cloud device farm.
**Why:** Keep the test environment predictable and private.

## D4 — One config source
**Rule:** `config/tester.config.json` is the sole source for paths, AVD, image, port, timeouts, and output directories.
**Why:** Avoid drift and machine-specific hardcoding.

## D5 — Generic engine, data-driven flows
**Rule:** Scripts test arbitrary APKs; app-specific actions and assertions belong in JSON flow files.
**Why:** Separate reusable mechanics from app behavior.

## D6 — Muse Number 3 first use
**Rule:** The example checks that three slots open and swipe switching works. Separate logins require human review of genuine sessions/screenshots; the flow must not claim automated login isolation.
**Why:** Avoid claiming an unimplemented authentication assertion.

## D7 — Eye-catching, age-gated page
**Rule:** Keep `index.html` self-contained. Do not place payment embeds in the DOM or load payment providers until age confirmation. Owner direction dated 2026-10-23 removes Ko-fi and its floating widget; show only PayPal, GitHub Sponsors, Buy Me a Coffee, NOWPayments, and Stripe in that order.
**Why:** Keep payment content age-gated and honor the owner’s updated payment choices. This amendment supersedes the earlier D7 Ko-fi requirement in the source tree.

## D8 — Generated evidence is not committed
**Rule:** Ignore APKs, reports, screenshots, SDK/AVD data, and keep output directories with `.gitkeep` only.
**Why:** Evidence and machine artifacts are per-run, not source.

## D9 — Boring scripts
**Rule:** Bash scripts use strict mode, are safe to rerun, and use exit 0 for PASS, 1 for test failure, 2 for setup/environment error.
**Why:** Predictable scripts are easier to audit and automate.

## D10 — Fixed report shape
**Rule:** Preserve the field order in `templates/test-report.md` across runs.
**Why:** Reports from different builds should be comparable.
