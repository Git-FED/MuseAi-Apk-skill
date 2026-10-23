# MuseAi-Skill-apk-testing — FULL File Tree with Prompts
**"APK Tester Skill"** — a Muse skill that lets Muse3 run-test any APK end-to-end on a virtual phone (Android emulator / AVD): install → launch → screenshot every screen → check logcat for crashes → walk the main flows → PASS/FAIL report with the screenshots as proof. No physical phone needed.

## How to use this document
- This is the **definitive repository layout** for `github.com/Git-FED/MuseAi-Skill-apk-testing`. Build top-to-bottom in the "Build order" section at the end.
- Every file has three things: **PURPOSE** (one line), **DETAILS** (key technical facts), **BUILD PROMPT** (copy-paste into any AI — including Muse3 — to generate that exact file with no follow-up questions).
- Source spec: the "APK Tester Skill" side chat MEMORY.md (filed 2026-10-23, Git-FED's explicit order; index.html + age-gated payment embeds added same day). Where this tree and the spec disagree, the **Decisions** section below rules.
- Standing constraints baked into every prompt: GitHub is ZERO WRITES for Muse3 — Git-FED creates/pushes the repo, Muse3 writes files locally and verifies. No downloads/installs without Git-FED's go on the exact source. **SPEC ONLY until Git-FED orders the build** — this document is not a build order.

## Decisions & gap resolutions
- **D1 — Spec only / one approved download.** Nothing is installed and no build starts from this document. The ONE download Git-FED approves once is the Android SDK + emulator install (`setup/install-sdk.sh`). Every other step is pure file-writing.
- **D2 — Proof, never claims.** Every test report carries screenshots + a logcat verdict. A run with no screenshots is not a test. PASS requires: app installed, app launched, no fatal exception in logcat, every flow step completed.
- **D3 — Virtual phone only.** Tests run on one AVD (Android Virtual Device) on Muse3's machine. No physical phone, no USB debugging, no cloud device farm in v1.
- **D4 — One config source.** `config/tester.config.json` is the single source for: AVD name, system image, adb/emulator paths, boot timeout, screenshot/output directories, logcat window. No script hardcodes a path or an AVD name — every script reads the config.
- **D5 — Generic engine, flows are data.** The scripts test ANY apk. What to tap/swipe/check lives in a flow file (JSON), never hardcoded in a script. The first flow file ships as `examples/muse-number-three.flow.json`.
- **D6 — Muse Number 3 flow check (the first real use).** All 3 slots open, swipe switching works, the 3 logins stay separate (the QA isolation test, run live). The debug APK it will test: GitHub Actions run 39981992531, package `com.fedos.musenumberthree`, INTERNET-only, WebView + MultiProfile + muse.ai — static-tested only so far; this skill closes the live-test gap.
- **D7 — index.html is eye-catching AND age-gated.** Single self-contained HTML file, no build step, no framework. Payment/support section sits BEHIND an age gate (confirm before reveal). All 6 payment embeds are Git-FED's verbatim snippets (file 3, below) — never regenerated, never re-typed from memory. Placement is law: Ko-fi directly UNDER PayPal.
- **D8 — Nothing generated is committed.** APKs under test, test reports, screenshots, the SDK, and the AVD itself never enter the repo (root `.gitignore`). `output/` ships with `.gitkeep` placeholders only.
- **D9 — Scripts are boring on purpose.** Bash, `set -euo pipefail`, idempotent, safe to re-run. Exit codes are the verdict: 0 = PASS, 1 = FAIL (crash/assertion), 2 = setup/environment error. Every script prints what it did and where the evidence is.
- **D10 — Report shape is fixed.** `templates/test-report.md` never changes shape between runs: APK identity (package, version, SHA-256), device (AVD + Android version), screens captured, flows walked, logcat verdict, PASS/FAIL. Reports from different days must be comparable at a glance.

## The tree (45 files)

```
github.com/Git-FED/MuseAi-Skill-apk-testing
├── README.md
├── SKILL.md
├── index.html
├── LICENSE
├── .gitignore
├── CHANGELOG.md
├── .github
│   └── workflows
│       └── lint.yml
├── assets
│   ├── icon.png
│   ├── icon-source.svg
│   ├── og-image.png
│   └── favicon
│       ├── favicon.ico
│       ├── favicon.svg
│       ├── favicon-16x16.png
│       ├── favicon-32x32.png
│       ├── apple-touch-icon.png
│       ├── android-chrome-192x192.png
│       ├── android-chrome-512x512.png
│       └── site.webmanifest
├── config
│   └── tester.config.json
├── docs
│   ├── ultimate-file-tree.md
│   ├── DECISIONS.md
│   ├── SETUP.md
│   ├── USAGE.md
│   └── TROUBLESHOOTING.md
├── prompts
│   ├── BUILD-PROMPT.md
│   ├── EMAIL-LIST-PROMPT.md
│   ├── HTML-PROMPT.md
│   ├── ICON-PROMPT.md
│   ├── PROMO-CODES-PROMPT.md
│   └── README-PROMPT.md
├── setup
│   ├── install-sdk.sh
│   ├── create-avd.sh
│   └── verify-setup.sh
├── scripts
│   ├── test-apk.sh
│   ├── launch-and-capture.sh
│   ├── logcat-check.sh
│   ├── walk-flows.sh
│   ├── capture-screen.sh
│   └── cleanup.sh
├── templates
│   ├── test-report.md
│   └── flow-checklist.md
├── examples
│   ├── muse-number-three.flow.json
│   └── sample-report.md
└── output
    ├── reports
    │   └── .gitkeep
    └── screenshots
        └── .gitkeep
```

> Notes: the Android SDK, the emulator, and the AVD live OUTSIDE the repo (paths in `config/tester.config.json`) — they are the one approved download (D1), never repo files. Every icon in this tree is a real committed file (same rule as Muse Number 3 D14): the density PNGs are exported once from `assets/icon-source.svg` and committed, not regenerated per build. Raster icons are PNG only — never WebP.

---

## REPO ROOT

### 1. `README.md`
**PURPOSE:** The repo's front door — what the skill does, how a test run works, how to start.
**DETAILS:** Plain language. The one-sentence version up top: "Muse tests the APK itself — on a virtual phone, with screenshots as proof." Links: SKILL.md (the skill), docs/SETUP.md, docs/USAGE.md, index.html (the landing page). Support contact: museai@fedpromptly.com. No download claims until setup has actually run on Git-FED's go. The FINAL README is produced by running `prompts/README-PROMPT.md` (file 43, Git-FED's verbatim landing-page prompt) against the real repo — its rules override this summary prompt wherever they differ (inspect first, real demo/screenshots only, never invent features/links/metrics/deployment status).
> **BUILD PROMPT:**
> ```
> Write README.md for "MuseAi-Skill-apk-testing" (Git-FED's Muse skill repo).
> CONTEXT: A skill that lets a Muse agent run-test any Android APK end-to-end on a virtual phone (Android emulator/AVD): install the APK, launch it, screenshot every screen, check logcat for crashes, walk the main flows, and produce a PASS/FAIL report with the screenshots as proof. No physical phone needed.
> SECTIONS: what it is (2-3 lines), the test routine (numbered, the 6 steps above), the two parts (one-time setup vs every-time routine), quick start (run setup/verify-setup.sh, then scripts/test-apk.sh <apk> <flow.json>), repo layout (one line per folder), rules (proof = screenshots + logcat verdict; reports never committed), support contact museai@fedpromptly.com.
> CONSTRAINTS: Plain language, under 100 lines, no pricing, no store links, no claims that setup has already run.
> DONE = a reader understands what gets tested, how, and what proof comes out, in under 60 seconds.
> ```

### 2. `SKILL.md`
**PURPOSE:** The skill itself — what Muse loads: when to use it, the routine, the rules.
**DETAILS:** This is the file that makes the repo a *skill* and not just scripts. Must state the trigger (an APK needs live testing), the exact routine in order, the PASS/FAIL criteria (D2), the exit-code meaning (D9), and the hard rule: never report a result without screenshots + logcat evidence attached. Points at config/tester.config.json as the only place paths/AVD names live (D4). States the one-download rule (D1) in plain words.
> **BUILD PROMPT:**
> ```
> Write SKILL.md for a Muse skill named "apk-tester".
> CONTEXT: The skill lets the agent run-test any Android APK on a local Android emulator (AVD): install -> launch -> screenshot every screen -> check logcat for crashes/fatal exceptions -> walk the flows defined in a flow JSON -> fill templates/test-report.md and return PASS/FAIL with screenshots as proof.
> SECTIONS: name + one-line description; WHEN TO USE (user hands over an APK, asks "does it run / does it crash / test this build", or a known flow check like Muse Number 3's 3-slot isolation test); PREREQUISITES (setup/verify-setup.sh must pass; if it fails, STOP and report setup error exit 2 — never improvise an install, the SDK install is a one-time owner-approved download); THE ROUTINE (numbered steps calling scripts/test-apk.sh, scripts/launch-and-capture.sh, scripts/logcat-check.sh, scripts/walk-flows.sh, scripts/cleanup.sh in order); PASS/FAIL RULES (PASS only if installed + launched + zero fatal exceptions + every flow step done; anything else is FAIL with the evidence named); EVIDENCE RULE (no result is reported without the screenshot set and the logcat verdict — "it worked" without proof is a failed test); CONFIG RULE (all paths/AVD names/timeouts come from config/tester.config.json, never hardcoded).
> CONSTRAINTS: Written as instructions to the agent, second person, imperative. Under 150 lines.
> DONE = an agent with no other context can run a correct, evidence-backed APK test from this file alone.
> ```

### 3. `index.html`
**PURPOSE:** The eye-catching landing page for the repo — and its age-gated payment/support card ("paypal fedpromptly card").
**DETAILS:** Single self-contained HTML file (inline CSS/JS, no build step, no framework). Sections: hero (phone mockup showing a test run + big PASS badge), the 6-step routine as a visual strip, a sample report card, the Muse Number 3 first-use story, the JOIN EMAIL LIST widget + Supabase auth modal (file 44), then the AGE-GATED support section, then the PROMO CODES section (file 45), then the FED-OS footer (file 3, step 8). Age gate: full-section overlay, visitor confirms age before ANY payment embed loads or shows (embeds are injected only after confirmation — not merely hidden behind CSS). Payment order is law: (1) PayPal subscription, (2) Ko-fi directly UNDER PayPal, (3) GitHub Sponsors, (4) Buy Me a Coffee, (5) NOWPayments, (6) Stripe. All embeds verbatim from the spec (below in this prompt) — never regenerated. Uses assets/icon.png, assets/og-image.png, and the assets/favicon/ set. The full copy-paste generation prompt for this file also lives in prompts/HTML-PROMPT.md.
> **BUILD PROMPT:**
> ```
> Write index.html — a single, self-contained, eye-catching landing page for "APK Tester Skill" (Git-FED's Muse skill: Muse run-tests any Android APK on a virtual phone and returns a PASS/FAIL report with screenshots as proof). Inline CSS + JS only, no build step, no external framework, dark theme with one loud accent color, big type, mobile-first.
> SECTIONS IN ORDER:
> 1. HERO: headline "Your AI tests the APK. Screenshots prove it." + subline (install -> launch -> screenshot every screen -> logcat crash check -> walk the flows -> PASS/FAIL report) + a CSS phone mockup showing a fake test run ending in a green PASS badge + button "See how it works" scrolling to section 2.
> 2. THE ROUTINE: 6 numbered cards (Install, Launch, Screenshot, Logcat, Walk flows, Report), one line each.
> 3. SAMPLE REPORT: a styled card copying the shape of templates/test-report.md (package, SHA-256, screens captured, flows walked, logcat verdict, PASS) using the Muse Number 3 example (package com.fedos.musenumberthree).
> 4. FIRST JOB: short section — built to live-test Muse Number 3: all 3 slots open, swipe switching works, 3 logins stay separate.
> 5. JOIN EMAIL LIST: the FedPromptly email-list widget from prompts/EMAIL-LIST-PROMPT.md (file 44) — Discord-style invite widget (green status dot, "Join now", typewriter email placeholder, hint "Click to join our email list") opening the Supabase auth modal (Join Email List / Sign In toggle, forgot password, logged-in thank-you view). Styles scoped so they cannot break the rest of the page; every element ID appears exactly once.
> 6. AGE-GATED SUPPORT ("paypal fedpromptly card"): the whole payment block sits behind an age gate — an overlay with an "I confirm I am of legal age" button; NO payment embed is in the DOM until the visitor confirms (inject the embeds with JS after confirmation, remember the confirmation in sessionStorage). After the gate, show the embeds in THIS EXACT ORDER, verbatim, unchanged:
>    (a) PAYPAL:
>    <div id="paypal-button-container-P-4FD24238VX4902214NK2XP2Y"></div>
>    <script src="https://www.paypal.com/sdk/js?client-id=BAA_ndqaWMyQwTnDZ0LXwLQ22jdJo9uxkeXYqmBbF-hD41HMiZ83mvOcx1Kti0b6ZfXfje7Q1ievNaS8Ok&vault=true&intent=subscription" data-sdk-integration-source="button-factory"></script>
>    <script>
>      paypal.Buttons({
>          style: { shape: 'rect', color: 'gold', layout: 'vertical', label: 'subscribe' },
>          createSubscription: function(data, actions) {
>            return actions.subscription.create({ plan_id: 'P-4FD24238VX4902214NK2XP2Y', quantity: 1 });
>          },
>          onApprove: function(data, actions) { alert(data.subscriptionID); }
>      }).render('#paypal-button-container-P-4FD24238VX4902214NK2XP2Y');
>    </script>
>    (b) KO-FI — directly UNDER the PayPal button:
>    <script src='https://storage.ko-fi.com/cdn/scripts/overlay-widget.js'></script>
>    <script>
>      kofiWidgetOverlay.draw('fedpromptly', {
>        'type': 'floating-chat',
>        'floating-chat.donateButton.text': 'Support me',
>        'floating-chat.donateButton.background-color': '#00b9fe',
>        'floating-chat.donateButton.text-color': '#fff'
>      });
>    </script>
>    (c) GITHUB SPONSORS:
>    <iframe src="https://github.com/sponsors/Git-FED/button" title="Sponsor Git-FED" height="32" width="114" style="border: 0; border-radius: 6px;"></iframe>
>    (d) BUY ME A COFFEE:
>    <a href="https://www.buymeacoffee.com/fedpromptly"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a book&emoji=📖&slug=fedpromptly&button_colour=FFDD00&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=ffffff" /></a>
>    (e) NOWPAYMENTS:
>    <a href="https://nowpayments.io/payment/?iid=5997958570&source=button" target="_blank" rel="noreferrer noopener"><img src="https://nowpayments.io/images/embeds/payments-button-white.svg" alt="Cryptocurrency & Bitcoin payment button by NOWPayments" /></a>
>    (f) STRIPE:
>    <script async src="https://js.stripe.com/v3/buy-button.js"></script>
>    <stripe-buy-button buy-button-id="buy_btn_1UJKaaJaRf233kfWKZ81fcIe" publishable-key="pk_live_51UIdAGJaRf233kfWlFacR31IYVGdjCVAttNFzIgQGXQzrUdc894iJcBqamRZNwF11z2AN5kvjyzitor462f2egVI00UmKj0sd8"></stripe-buy-button>
> 7. PROMO CODES: three cards from prompts/PROMO-CODES-PROMPT.md (file 45), text verbatim — Muse (code 5F2V31, https://muse.ai/join), Manus AI (invite code G3ADN), Teamily (code 2U6Q8D, https://teamily.ai/i/2U6Q8D). Each code shown big/monospace with its exact redeem instructions; no code is shortened, reworded, or "improved".
> 8. FOOTER — FED-OS public footer layout (Git-FED spec, 2026-10-23; full prompt text below this file's section in the spec under "FOOTER PROMPT"). Four columns, PUBLIC links only, exactly these:
>    FED-OS: Explore the Ecosystem https://www.fedpromptly.org | Join FED-OS Membership https://www.fedpromptly.com/aid | Storefront https://www.jabburr.com/fed-os | Whop https://whop.com/fedpromptly/
>    Contact: contact@fedpromptly.com | support@fedpromptly.com | business@fedpromptly.com | careers@fedpromptly.com (all mailto)
>    Media: Articles https://substack.com/@fedpromptly | Blog Post https://fedpromptly.wordpress.com/ | GitFed Blog https://gitfed.substack.com/ | Artwork https://www.deviantart.com/fedpromptly | Social Media https://bsky.app/profile/fed-os.bsky.social | Advertisement / X https://x.com/Fedpromptly  (Facebook is SKIPPED per his recommended footer)
>    Support: Supporters https://www.patreon.com/c/FEDpromptly | Tips / Donations https://buymeacoffee.com/fedpromptly | Developers (Discord) https://discord.gg/Jm4XStx4Pf
>    NEVER IN THE FOOTER: Private Matrix (https://matrix.to/#/#fed-os:matrix.org — 18+, country-locked CA/CH/RU/IR/SO/TM; it belongs behind a gated "Private Communities" page: 18+ warning + checkbox confirmation + country eligibility check, then reveal) and Personal Substack (https://substack.com/@gitfed — author bio/personal page only). Premium/member links are fine as teaser landing pages; private/restricted and internal links stay out entirely. A small bottom line under the columns: "APK Tester Skill by Git-FED — FedPromptly".
> HEAD: title "APK Tester Skill — Muse tests your APK, screenshots prove it", meta description, Open Graph tags pointing at assets/og-image.png, favicon links to the assets/favicon/ set, theme-color matching the accent.
> CONSTRAINTS: the 6 embeds byte-for-byte as given (IDs, URLs, order) — do not shorten, reformat, or substitute them; gate must actually withhold the embeds, not just cover them; page must still read perfectly with JS disabled except the gated section, which shows a "enable JS + confirm age" note; no .html links to other pages (this is the only page).
> DONE = opening the file shows an eye-catching page, the support section is locked until age confirmation, and after confirming, all 6 payment options appear in the exact order above with Ko-fi directly under PayPal.
> ```

### 4. `LICENSE`
**PURPOSE:** Legal terms for the code.
**DETAILS:** Git-FED's call. Placeholder until he decides — recommend proprietary/all-rights-reserved draft, do NOT ship v1.0.0 with this unresolved.
> **BUILD PROMPT:**
> ```
> Write a placeholder LICENSE for "MuseAi-Skill-apk-testing" (Git-FED's Muse skill).
> CONTEXT: Owner-published skill, no open-source intent stated.
> CONSTRAINTS: Do not pick the license for him. Write "License terms to be finalized by the owner before v1.0.0" plus a short proprietary draft (all rights reserved, no redistribution). Under 20 lines.
> DONE = file exists, decision marked pending, usable proprietary draft present.
> ```

### 5. `.gitignore`
**PURPOSE:** Keeps secrets, downloads, and test evidence out of the repo — permanently.
**DETAILS:** Must cover (D8): `*.apk`, `*.aab`, `output/reports/*`, `output/screenshots/*` (but keep the `.gitkeep` files), `sdk/`, `.android/`, `*.img`, `*.qcow2`, `local.properties`, `.DS_Store`. The APK line is the most important line in the repo — an APK under test is never committed.
> **BUILD PROMPT:**
> ```
> Write .gitignore for "MuseAi-Skill-apk-testing" (bash skill repo + Android emulator testing).
> MUST IGNORE: *.apk, *.aab, output/reports/* and output/screenshots/* (with !.gitkeep exceptions), sdk/, .android/, *.img, *.qcow2, *.ini.lock, local.properties, .DS_Store, *.log.
> DONE = every pattern above present, APK patterns at the top under the comment "# NEVER commit an APK under test, a report, or a screenshot".
> ```

### 6. `CHANGELOG.md`
**PURPOSE:** Version history, one entry per release.
**DETAILS:** Starts with v0.1.0 (unreleased) — "repo scaffold + full file tree". Every shipped change lands here before a version tag.
> **BUILD PROMPT:**
> ```
> Write CHANGELOG.md for "MuseAi-Skill-apk-testing" with a single entry: v0.1.0 — Unreleased — "Repository scaffold. Full file tree with prompts, SKILL.md, age-gated index.html with the FedPromptly payment card, setup + test scripts specced. Nothing installed, no build run yet." Keep a "## [Unreleased]" section on top for future entries.
> DONE = file exists with the v0.1.0 entry and an empty Unreleased section.
> ```

---

## CI

### 7. `.github/workflows/lint.yml`
**PURPOSE:** Free quality gate on every push — shell scripts and HTML never ship broken.
**DETAILS:** GitHub Actions, ubuntu-latest, on push + pull_request. Jobs: shellcheck on setup/*.sh + scripts/*.sh; a lightweight HTML check on index.html (tidy or html5validator); JSON validation of config/*.json + examples/*.json. No secrets, no deployments, no APK builds (this repo builds nothing).
> **BUILD PROMPT:**
> ```
> Write .github/workflows/lint.yml for "MuseAi-Skill-apk-testing".
> REQUIREMENTS: trigger on push and pull_request; one job on ubuntu-latest with steps: checkout, install shellcheck, run shellcheck on setup/*.sh and scripts/*.sh (fail on error level), validate config/tester.config.json and examples/*.json with python -m json.tool, run a basic HTML validation on index.html.
> CONSTRAINTS: No secrets, no deploy steps, no artifact uploads. Under 50 lines.
> DONE = a push with a broken shell script, invalid JSON, or malformed HTML fails the workflow.
> ```

---

## ASSETS

### 8. `assets/icon.png`
**PURPOSE:** The skill's master icon — a phone with a green PASS check.
**DETAILS:** 1024×1024 PNG, exported from icon-source.svg (file 9). Used by README, index.html hero, and the store listing. PNG only, never WebP. Generation prompt lives in prompts/ICON-PROMPT.md.
> **BUILD PROMPT:**
> ```
> Export assets/icon.png at 1024x1024 from assets/icon-source.svg (file 9 in this tree). If the SVG does not exist yet, stop and generate it first from prompts/ICON-PROMPT.md.
> DONE = a 1024x1024 PNG, transparent background, the phone-and-check mark crisp at 32px.
> ```

### 9. `assets/icon-source.svg`
**PURPOSE:** The editable source art for every icon in the repo.
**DETAILS:** Simple flat vector: rounded phone outline, a screenshot stack inside, one bold check badge. Two colors max + the accent from index.html — the icon and the page must read as one brand. No text in the icon.
> **BUILD PROMPT:**
> ```
> Write assets/icon-source.svg — source art for the "APK Tester Skill" icon.
> DESIGN: flat vector, viewBox 0 0 1024 1024. A rounded-rectangle smartphone (dark body) centered, inside it three stacked screenshot cards slightly fanned, and a bold circular check badge (accent green) overlapping the phone's bottom-right corner. Two flat colors plus the green accent. No text, no gradients except one subtle body shade, no photo elements.
> DONE = the SVG opens in a browser, reads instantly at 32px as "phone + tested/passed", and exports cleanly to PNG.
> ```

### 10. `assets/og-image.png`
**PURPOSE:** The social/share image for index.html (Open Graph).
**DETAILS:** 1200×630 PNG. The icon, the headline from the hero, and a PASS badge — the page's whole pitch in one image. Exported once and committed.
> **BUILD PROMPT:**
> ```
> Create assets/og-image.png, 1200x630 PNG, for "APK Tester Skill".
> DESIGN: dark background matching index.html, assets/icon.png on the left, headline text on the right: "Your AI tests the APK." / "Screenshots prove it." + a green PASS pill. Flat, high contrast, no small text below 40px.
> DONE = a 1200x630 PNG that reads clearly as a thumbnail in a chat/social preview.
> ```

### 11–18. `assets/favicon/` (8 files)
**PURPOSE:** The full favicon set for index.html — every browser/platform surface covered, every file real and committed.
**DETAILS:** `favicon.ico` (multi-size), `favicon.svg`, `favicon-16x16.png`, `favicon-32x32.png`, `apple-touch-icon.png` (180×180), `android-chrome-192x192.png`, `android-chrome-512x512.png`, `site.webmanifest` (name "APK Tester Skill", theme/background matching index.html). All raster exports come from icon-source.svg. One section, one prompt — the set is generated together or not at all.
> **BUILD PROMPT:**
> ```
> Generate the complete favicon set in assets/favicon/ from assets/icon-source.svg:
> favicon.ico (16/32/48), favicon.svg (the source, optimized), favicon-16x16.png, favicon-32x32.png, apple-touch-icon.png (180x180, full-bleed background, no transparency), android-chrome-192x192.png, android-chrome-512x512.png, and site.webmanifest ({"name":"APK Tester Skill","short_name":"APK Tester","icons":[{192},{512}],"theme_color":<index.html accent>,"background_color":<index.html background>,"display":"standalone"}).
> DONE = all 8 files exist, each PNG is exactly its named size, and the manifest references the two android-chrome files correctly.
> ```

---

## CONFIG

### 19. `config/tester.config.json`
**PURPOSE:** The ONE place every path, name, and timeout lives (D4) — scripts read this, never hardcode.
**DETAILS:** Keys: `sdk_root`, `avd_name` ("apk-tester-phone"), `system_image` (e.g. `system-images;android-34;google_apis;x86_64`), `emulator_port` (5554), `boot_timeout_seconds` (180), `screenshot_dir` (`output/screenshots`), `report_dir` (`output/reports`), `logcat_lines` (2000), `default_flow` (`examples/muse-number-three.flow.json`). Paths relative to repo root where possible; absolute only for the SDK.
> **BUILD PROMPT:**
> ```
> Write config/tester.config.json for "MuseAi-Skill-apk-testing".
> KEYS (exactly these): sdk_root ("~/Android/Sdk" placeholder with a comment-free note in docs/SETUP.md, JSON has no comments), avd_name "apk-tester-phone", system_image "system-images;android-34;google_apis;x86_64", emulator_port 5554, boot_timeout_seconds 180, screenshot_dir "output/screenshots", report_dir "output/reports", logcat_lines 2000, default_flow "examples/muse-number-three.flow.json".
> CONSTRAINTS: valid JSON, 2-space indent, no trailing commas, no extra keys.
> DONE = python -m json.tool validates it, and every key a script needs exists here and nowhere else.
> ```

---

## DOCS

### 20. `docs/ultimate-file-tree.md`
**PURPOSE:** This document, committed into the repo — the build contract travels with the code.
**DETAILS:** Byte-for-byte copy of `~/workspace/apk-tester-skill/ultimate-file-tree.md`. If the tree changes, this file changes in the same commit.
> **BUILD PROMPT:**
> ```
> Copy the approved "MuseAi-Skill-apk-testing — FULL File Tree with Prompts" document into docs/ultimate-file-tree.md unchanged.
> DONE = the file matches the approved document exactly (diff is empty).
> ```

### 21. `docs/DECISIONS.md`
**PURPOSE:** The binding decisions D1–D10, one page, so no builder has to guess.
**DETAILS:** Copied from the Decisions section of this tree, expanded with one "why" line each. Changes only on Git-FED's order, logged in CHANGELOG.md.
> **BUILD PROMPT:**
> ```
> Write docs/DECISIONS.md for "MuseAi-Skill-apk-testing": decisions D1-D10 from the ultimate file tree (spec-only/one approved download; proof never claims; virtual phone only; one config source; generic engine, flows are data; Muse Number 3 flow check; index.html eye-catching + age-gated with verbatim embeds and Ko-fi under PayPal; nothing generated is committed; boring scripts with exit-code verdicts; fixed report shape). One section per decision: the rule, then one line of "why".
> DONE = all 10 decisions present, no new decisions invented.
> ```

### 22. `docs/SETUP.md`
**PURPOSE:** The one-time setup, explained for a human — what gets downloaded, where it lives, how to verify.
**DETAILS:** Covers: what install-sdk.sh downloads (Android command-line tools + emulator + the config's system image) and that this is the ONE owner-approved download (D1); running create-avd.sh; running verify-setup.sh and what a green result looks like; disk space expectations; how to wipe and redo (delete SDK + AVD, re-run). No step may be run "to try it" — setup runs on Git-FED's go only.
> **BUILD PROMPT:**
> ```
> Write docs/SETUP.md for "MuseAi-Skill-apk-testing".
> SECTIONS: before you start (the SDK/emulator download happens ONCE and only on the repo owner's go — say this first and plainly); what gets installed (Android cmdline-tools, platform-tools/adb, emulator, the system image named in config/tester.config.json, and where each lands on disk); step 1 run setup/install-sdk.sh; step 2 run setup/create-avd.sh; step 3 run setup/verify-setup.sh and the exact green output to expect; disk + time expectations (label them estimates); start-over instructions (remove the AVD and SDK, re-run from step 1); pointer to docs/TROUBLESHOOTING.md.
> CONSTRAINTS: plain language, commands in code blocks, under 120 lines.
> DONE = a human can do the one-time setup from this page alone and know when it's actually done.
> ```

### 23. `docs/USAGE.md`
**PURPOSE:** How to run a test — the every-time routine, for a human or an agent.
**DETAILS:** The command (`scripts/test-apk.sh <apk-path> <flow-json>`), what happens step by step, where the report + screenshots land, how to read the verdict (exit codes 0/1/2, D9), how to write a flow file (point at examples/ + templates/flow-checklist.md), and the Muse Number 3 worked example end-to-end.
> **BUILD PROMPT:**
> ```
> Write docs/USAGE.md for "MuseAi-Skill-apk-testing".
> SECTIONS: the one command (scripts/test-apk.sh path/to/app.apk path/to/flow.json — plus the default-flow shortcut); what happens next, step by step (boot AVD if needed, install, launch, capture, logcat, walk flows, report, cleanup); where the outputs land (output/reports/, output/screenshots/, timestamped per run); reading the result (PASS/FAIL + exit codes 0 PASS, 1 FAIL, 2 setup error, and what each obliges you to do); writing your own flow file (anatomy of examples/muse-number-three.flow.json + templates/flow-checklist.md); worked example: live-testing the Muse Number 3 debug APK (package com.fedos.musenumberthree) with the example flow.
> CONSTRAINTS: plain language, under 140 lines, every claim about output locations must match config/tester.config.json defaults.
> DONE = a first-time user can run a test and correctly read its verdict from this page alone.
> ```

### 24. `docs/TROUBLESHOOTING.md`
**PURPOSE:** Every known failure, its cause, and its fix — so a stuck run is a lookup, not a research project.
**DETAILS:** Exactly **9 entries** — the same 9 the BUILD PROMPT below lists, counted the same way: (1) emulator boot timeout, (2) virtualization (KVM/HAXM) unavailable, (3) adb device offline or unauthorized, (4) install fails (INSTALL_FAILED_* meanings — both named codes in this one entry), (5) app launches to a black screen, (6) logcat empty, (7) screenshots black (secure flag / FLAG_SECURE), (8) AVD snapshot corrupt, (9) emulator port (5554) busy. Each entry: symptom, likely cause, exact fix command. Rule printed at top: a setup failure is exit 2 — fix setup, never fake a result.
> **BUILD PROMPT:**
> ```
> Write docs/TROUBLESHOOTING.md for "MuseAi-Skill-apk-testing" covering exactly these failures: emulator boot timeout; virtualization (KVM/HAXM) unavailable; adb shows device offline or unauthorized; INSTALL_FAILED_UPDATE_INCOMPATIBLE and INSTALL_FAILED_VERSION_DOWNGRADE; app opens to a black screen; logcat returns nothing; screenshots come out black (FLAG_SECURE); AVD fails to start from a corrupt snapshot; emulator port already in use.
> FORMAT per entry: SYMPTOM (what you see, verbatim where possible), CAUSE (one line), FIX (exact commands, using paths from config/tester.config.json — no invented paths).
> TOP RULE, printed first: "A setup/environment failure is exit code 2. Fix the setup. Never report a test result from a run that didn't happen."
> DONE = all 9 entries present in the format above.
> ```

---

## PROMPTS

### 25. `prompts/BUILD-PROMPT.md`
**PURPOSE:** The master prompt — paste this into an AI and it builds the whole repo in order.
**DETAILS:** References docs/ultimate-file-tree.md as the contract, states the build order (end of this document), and repeats the standing constraints (D1, D8, D9, GitHub zero-writes). One file at a time, verify each before the next.
> **BUILD PROMPT:**
> ```
> Write prompts/BUILD-PROMPT.md — the master build prompt for "MuseAi-Skill-apk-testing".
> CONTENT: instruct the builder AI to (1) read docs/ultimate-file-tree.md and docs/DECISIONS.md first; (2) build files in the tree's Build Order, one at a time, using each file's own BUILD PROMPT; (3) after each file, verify it against that file's DONE line before continuing; (4) NEVER run setup/install-sdk.sh or setup/create-avd.sh (owner-approved download, owner's go only), never run any test, never push to GitHub; (5) stop and report if a prompt and the spec disagree — the spec wins.
> DONE = a builder following only this file produces the repo exactly as specced, with zero installs and zero pushes.
> ```

### 26. `prompts/HTML-PROMPT.md`
**PURPOSE:** The standalone copy-paste prompt for index.html — the page can be rebuilt without opening the big tree.
**DETAILS:** Byte-for-byte the BUILD PROMPT of file 3, including all 6 verbatim payment embeds and the age-gate requirement. If this file and file 3 ever disagree, file 3 (the tree) wins and this file gets fixed.
> **BUILD PROMPT:**
> ```
> Write prompts/HTML-PROMPT.md containing, verbatim, the full BUILD PROMPT for index.html exactly as written in docs/ultimate-file-tree.md file 3 — including the age-gate requirement, the exact payment order (PayPal, Ko-fi directly under PayPal, GitHub Sponsors, Buy Me a Coffee, NOWPayments, Stripe), and all 6 embed snippets byte-for-byte.
> DONE = diffing the prompt in this file against file 3's prompt shows no difference.
> ```

### 27. `prompts/ICON-PROMPT.md`
**PURPOSE:** The generation prompt for the icon set — art direction in one paste.
**DETAILS:** Describes the mark (phone + screenshot stack + PASS check badge), colors tied to index.html, sizes needed, and the export list matching files 8–18. PNG only, never WebP.
> **BUILD PROMPT:**
> ```
> Write prompts/ICON-PROMPT.md — the art-generation prompt for the "APK Tester Skill" icon.
> CONTENT: describe the mark (rounded smartphone, three fanned screenshot cards inside, bold circular green check badge at bottom-right, flat, two colors + green accent, no text), the style rules (flat vector look, reads at 32px, dark body so it works on light and dark backgrounds), and the export list: assets/icon.png 1024x1024, assets/og-image.png 1200x630 (with the hero headline), and the full assets/favicon/ set — all PNG, never WebP.
> DONE = an image tool or designer given only this file produces the whole asset set consistently.
> ```

---

## SETUP (one-time — runs only on Git-FED's go, D1)

### 28. `setup/install-sdk.sh`
**PURPOSE:** The one approved download — installs the Android SDK + emulator onto Muse3's machine.
**DETAILS:** Bash, `set -euo pipefail`. Downloads the Android command-line tools from Google's official URL only (the exact URL is a named constant at the top of the script, shown to the owner before first run), unpacks to `sdk_root` from config, accepts licenses non-interactively, then uses sdkmanager to install: platform-tools, emulator, and the config's system image. Idempotent: if a component is already present it is skipped, not re-downloaded. Prints versions installed at the end. This script RUNNING is the download event — writing it is not.
> **BUILD PROMPT:**
> ```
> Write setup/install-sdk.sh (bash, set -euo pipefail) for "MuseAi-Skill-apk-testing".
> BEHAVIOR: read sdk_root and system_image from config/tester.config.json (python3 -c or jq if present — no other config parsing anywhere); define CMDLINE_TOOLS_URL at the top as a single clearly-commented constant pointing at Google's official Android command-line tools download; download + unzip it into sdk_root/cmdline-tools/latest ONLY if missing; run sdkmanager --licenses acceptance; sdkmanager-install exactly: platform-tools, emulator, and the config's system_image — skipping any already installed; end by printing adb --version and emulator -version output.
> CONSTRAINTS: no sudo, no package-manager installs, no downloads from anywhere except the one official constant, re-runnable safely, every step echoes what it is doing.
> DONE = on a clean machine (after the owner's go) the SDK, adb, emulator, and system image are installed and version-printed; a second run changes nothing.
> ```

### 29. `setup/create-avd.sh`
**PURPOSE:** Creates the virtual phone (AVD) the tests run on.
**DETAILS:** Bash, `set -euo pipefail`. Uses avdmanager with the config's `avd_name` + `system_image`, a standard phone profile (e.g. pixel_6), sane defaults (2 GB RAM, 1080×2400). Idempotent: an existing AVD with the right name is verified, not recreated. Ends by listing AVDs (`emulator -list-avds`) as proof.
> **BUILD PROMPT:**
> ```
> Write setup/create-avd.sh (bash, set -euo pipefail) for "MuseAi-Skill-apk-testing".
> BEHAVIOR: read avd_name and system_image from config/tester.config.json; if an AVD with that name already exists, print "already exists" and exit 0; otherwise create it with avdmanager (device profile pixel_6, the config's system image, defaults for RAM/screen), then run emulator -list-avds and show the new AVD in the list.
> CONSTRAINTS: never delete or overwrite an existing AVD; fail with exit 2 and a clear message if the system image is missing (pointing at setup/install-sdk.sh + docs/SETUP.md).
> DONE = the named AVD exists and appears in emulator -list-avds.
> ```

### 30. `setup/verify-setup.sh`
**PURPOSE:** The green-light check — proves setup actually worked before any test is attempted.
**DETAILS:** Bash, `set -euo pipefail`. Checks, in order: config parses; adb exists and runs; emulator exists; the named AVD exists; boots the AVD headless, waits for `sys.boot_completed` within `boot_timeout_seconds`, runs a trivial adb shell command, shuts the emulator down cleanly. Prints PASS/FAIL per check, exit 0 only if all pass, exit 2 otherwise (D9 — a failed verify is a setup error, never a test result).
> **BUILD PROMPT:**
> ```
> Write setup/verify-setup.sh (bash, set -euo pipefail) for "MuseAi-Skill-apk-testing".
> CHECKS IN ORDER, each printed as PASS/FAIL with its name: (1) config/tester.config.json parses; (2) adb binary found at the config sdk_root and adb --version runs; (3) emulator binary found; (4) the config's avd_name appears in emulator -list-avds; (5) headless boot: start the emulator with -no-window -no-audio, poll adb shell getprop sys.boot_completed until 1 or boot_timeout_seconds expires; (6) adb shell echo works; (7) clean shutdown via adb emu kill.
> CONSTRAINTS: always attempt the shutdown even on failure (trap); exit 0 only if ALL checks pass, else exit 2 with the failed check named; total added runtime after boot under 30 seconds.
> DONE = a machine that can run tests gets all-PASS + exit 0; removing the AVD makes it fail at check 4 with exit 2.
> ```

---

## SCRIPTS (the every-time routine)

### 31. `scripts/test-apk.sh`
**PURPOSE:** The main routine — one command runs the whole test and produces the report.
**DETAILS:** Bash, `set -euo pipefail`. Usage: `test-apk.sh <apk> [flow.json]` (flow defaults to config `default_flow`). Steps: verify setup quickly (adb + AVD present, else exit 2) → compute SHA-256 + package name (aapt/apkanalyzer if present, else adb) → boot AVD if not running → clear logcat → install APK → call launch-and-capture.sh → call walk-flows.sh → call logcat-check.sh → fill templates/test-report.md into report_dir with a timestamped name → call cleanup.sh → exit with the verdict code (0 PASS / 1 FAIL / 2 setup). Prints the report path + screenshot count as its last lines.
> **BUILD PROMPT:**
> ```
> Write scripts/test-apk.sh (bash, set -euo pipefail) — the main APK test routine for "MuseAi-Skill-apk-testing".
> USAGE: test-apk.sh <path-to.apk> [path-to-flow.json]; flow defaults to config/tester.config.json's default_flow; all paths/names/timeouts come from the config, none hardcoded.
> BEHAVIOR IN ORDER: (1) sanity: APK file exists, config parses, adb + named AVD available — any failure exits 2 naming the problem; (2) identify the APK: SHA-256 (sha256sum) + package name + version if a tool is available; (3) boot the emulator headless if not already running, wait for boot_completed within boot_timeout_seconds; (4) adb logcat -c; (5) adb install -r the APK (install failure = FAIL, record the exact INSTALL_FAILED_* string); (6) run scripts/launch-and-capture.sh; (7) run scripts/walk-flows.sh with the flow file; (8) run scripts/logcat-check.sh and capture its verdict; (9) render the report from templates/test-report.md into report_dir as <package>-<timestamp>.md with every field filled; (10) run scripts/cleanup.sh; (11) print the report path and screenshot count, exit 0 (PASS) / 1 (FAIL) / 2 (setup error) per the rules in SKILL.md.
> CONSTRAINTS: a failure at any step still produces a report saying where it failed — never exit silently; keep the emulator-running state as found (if this script booted it, cleanup shuts it down; if it was already running, leave it).
> DONE = one command on a valid APK + flow produces a filled report, a screenshot set, and the correct exit code.
> ```

### 32. `scripts/launch-and-capture.sh`
**PURPOSE:** Launches the app and screenshots every screen it can reach without a flow.
**DETAILS:** Bash, `set -euo pipefail`. Args: package name + screenshot dir (passed by test-apk.sh). Starts the launcher activity (`adb shell monkey` or `am start` with the resolved launcher intent), waits, calls capture-screen.sh for the first screen, then does a safe generic pass: open/close the app drawer-equivalents that exist for an app context — in-app: scroll down, scroll up, press Back once (only if the app doesn't exit) — capturing after each move. Numbered screenshots (`01-launch.png`, `02-scroll-down.png`, …). Never taps random coordinates that could buy/delete/send anything; generic pass is navigation-only.
> **BUILD PROMPT:**
> ```
> Write scripts/launch-and-capture.sh (bash, set -euo pipefail) for "MuseAi-Skill-apk-testing".
> ARGS: <package> <screenshot-dir> (both supplied by scripts/test-apk.sh).
> BEHAVIOR: resolve + start the app's launcher activity (adb shell cmd package resolve-activity or monkey -p <package> 1 as fallback); wait 3s; screenshot via scripts/capture-screen.sh as 01-launch.png; then a SAFE generic pass — swipe up (scroll down), screenshot 02; swipe down, screenshot 03; press Back once, screenshot 04 ONLY if the app is still in the foreground (check dumpsys) — capturing after each move, 2s settle between moves.
> CONSTRAINTS: navigation gestures only — never tap arbitrary points, never type, never interact with dialogs beyond dismissing a system permission dialog with Back; if the app is not foregrounded after launch, exit 1 with the foreground package printed.
> DONE = a launchable app yields at least the launch screenshot, numbered in order, in the given directory.
> ```

### 33. `scripts/logcat-check.sh`
**PURPOSE:** The crash verdict — pulls logcat and hunts the failures that make a test FAIL.
**DETAILS:** Bash, `set -euo pipefail`. Args: `<package> <output-file>` — exactly the ARGS in the BUILD PROMPT below; test-apk.sh calls it with the output file set to `logcat-<package>.txt` next to the report, and it reads the logcat buffer test-apk.sh cleared before launch (this script never clears it). Dumps up to config `logcat_lines` lines filtered to the package/process, greps for: `FATAL EXCEPTION`, `AndroidRuntime`, `Process <package> has died`, `ANR in <package>`, native crash markers. Writes the matching evidence lines to the given output file, prints `LOGCAT: CLEAN` or `LOGCAT: CRASH` + the first offending line, exit 0 clean / 1 crash. Silence is not clean: an empty log for a launched app is reported as `LOGCAT: EMPTY (suspicious)` and treated as FAIL by test-apk.sh.
> **BUILD PROMPT:**
> ```
> Write scripts/logcat-check.sh (bash, set -euo pipefail) for "MuseAi-Skill-apk-testing".
> ARGS: <package> <output-file>; reads logcat_lines from config/tester.config.json.
> BEHAVIOR: dump the logcat buffer (adb logcat -d, last N lines per config), filter to lines mentioning the package or AndroidRuntime; search for exactly these patterns: "FATAL EXCEPTION", "AndroidRuntime", "Process <package> has died", "ANR in", "signal 11 (SIGSEGV)"; write ALL matching lines (or the filtered dump if none) to <output-file>; print "LOGCAT: CRASH" + the first matching line and exit 1 if any pattern hits; print "LOGCAT: EMPTY (suspicious)" and exit 1 if the filtered dump is empty; otherwise print "LOGCAT: CLEAN" and exit 0.
> CONSTRAINTS: never clear the buffer (test-apk.sh owns clearing); matching is case-sensitive exactly as listed — no fuzzy extra patterns.
> DONE = an app that crashes on launch produces CRASH + exit 1 + evidence lines in the output file; a healthy app produces CLEAN + exit 0.
> ```

### 34. `scripts/walk-flows.sh`
**PURPOSE:** Walks a flow file — the taps, swipes, waits, and checks that make a test specific.
**DETAILS:** Bash (driving python3 for JSON parsing, or jq) with `set -euo pipefail`. Args: flow.json + screenshot dir. Step types (the whole v1 vocabulary): `launch` (package), `wait` (seconds), `tap` (x,y or UI-text via uiautomator dump match), `swipe` (direction or coordinates), `key` (BACK/HOME/ENTER), `type` (text), `screenshot` (name), `assert_foreground` (package), `assert_text` (string visible in UI dump). Executes in order, captures a screenshot after each `screenshot` step and on any failed assert, stops at first failure, prints `FLOW: PASS (n/n steps)` or `FLOW: FAIL at step k — <reason>`, exit 0/1. No other step types in v1 — a flow asking for one fails loudly.
> **BUILD PROMPT:**
> ```
> Write scripts/walk-flows.sh (bash, set -euo pipefail; python3 allowed for JSON parsing) for "MuseAi-Skill-apk-testing".
> ARGS: <flow.json> <screenshot-dir>.
> STEP VOCABULARY (support exactly these, reject anything else with a clear error): launch{package}, wait{seconds}, tap{xy:[x,y]} or tap{text:"..."} (find the text in a uiautomator dump and tap its center), swipe{direction: up|down|left|right}, key{name: BACK|HOME|ENTER}, type{text:"..."}, screenshot{name:"..."}, assert_foreground{package}, assert_text{text:"..."}.
> BEHAVIOR: run steps in order with a 1s settle after input steps; after each screenshot step (and automatically on any failed assert) capture via scripts/capture-screen.sh named <step-number>-<name>.png; stop at the first failed assert/unknown step; print "FLOW: PASS (n/n steps)" or "FLOW: FAIL at step k - <reason>"; exit 0/1 to match.
> CONSTRAINTS: coordinates are for the config AVD's screen — assert steps must not depend on pixel positions; a malformed flow file exits 2 (setup error), not 1.
> DONE = examples/muse-number-three.flow.json runs end-to-end against its app, and deleting one assert_text string makes it FAIL at that exact step.
> ```

### 35. `scripts/capture-screen.sh`
**PURPOSE:** The one screenshot primitive every other script uses — consistent names, verified files.
**DETAILS:** Bash, `set -euo pipefail`. Args: output path. Uses `adb exec-out screencap -p`, verifies the file exists and is > 10 KB (a black/failed capture is usually tiny — warn loudly if smaller), prints the path + size. If screencap fails, falls back to `adb shell screencap -p /sdcard/...` + pull. This is the only file in the repo that runs screencap.
> **BUILD PROMPT:**
> ```
> Write scripts/capture-screen.sh (bash, set -euo pipefail) for "MuseAi-Skill-apk-testing".
> ARGS: <output.png path>.
> BEHAVIOR: capture with adb exec-out screencap -p > output; if that fails or yields an empty file, fall back to adb shell screencap -p /sdcard/capture-screen.png + adb pull, then delete the device copy; verify the final file exists and report its size; if size < 10KB print "WARNING: screenshot suspiciously small (<path>) - possible black/secure screen" to stderr but still exit 0; exit 1 only if no file could be produced at all; print "<path> (<size> bytes)" as the only stdout line.
> CONSTRAINTS: create parent directories as needed; no other script in the repo may call screencap directly.
> DONE = every call yields a real PNG at the requested path, with size proof printed.
> ```

### 36. `scripts/cleanup.sh`
**PURPOSE:** Leaves the machine exactly as the test found it.
**DETAILS:** Bash, `set -euo pipefail`. Args: package name + a flag for whether test-apk.sh booted the emulator. Uninstalls the tested APK (unless the flow said keep — v1: always uninstall), clears the app data first, and shuts the emulator down ONLY if this run booted it. Prints what it removed. Never touches other AVDs, other packages, or anything outside the config's output dirs.
> **BUILD PROMPT:**
> ```
> Write scripts/cleanup.sh (bash, set -euo pipefail) for "MuseAi-Skill-apk-testing".
> ARGS: <package> <booted-by-us: true|false>.
> BEHAVIOR: adb shell pm clear <package> (ignore failure), adb uninstall <package> (ignore "not installed"), print both results; if booted-by-us is true, adb emu kill and wait until the emulator process is gone (max 30s); print a final "cleanup done" line listing exactly what was removed/stopped.
> CONSTRAINTS: never uninstall any package except the argument; never kill an emulator this run didn't boot; never delete reports or screenshots.
> DONE = after a test, the tested app is gone from the AVD and a self-booted emulator is off; a pre-running emulator is untouched.
> ```

---

## TEMPLATES

### 37. `templates/test-report.md`
**PURPOSE:** The fixed report shape (D10) — every run's verdict in the same format, filled by test-apk.sh.
**DETAILS:** Placeholders in `{{DOUBLE_BRACES}}`, nothing else varies. Fields: report title + timestamp; APK identity (file name, package, version, SHA-256); device (AVD name, system image, emulator port); setup check result; install result; launch result; screens captured (numbered list with file names); flows walked (flow file, steps passed/total, failed step if any); logcat verdict (CLEAN / CRASH / EMPTY + evidence file name + first offending line if crash); final verdict PASS/FAIL in big type; next action line (what a human should do with this result).
> **BUILD PROMPT:**
> ```
> Write templates/test-report.md for "MuseAi-Skill-apk-testing" — a Markdown report template with {{PLACEHOLDER}} tokens and NO example values filled in.
> SECTIONS IN ORDER: "# APK Test Report — {{PACKAGE}}"; meta table (Date {{TIMESTAMP}}, APK file {{APK_FILE}}, Package {{PACKAGE}}, Version {{VERSION}}, SHA-256 {{SHA256}}, AVD {{AVD_NAME}}, System image {{SYSTEM_IMAGE}}); "## Verdict: {{VERDICT}}" (PASS or FAIL); "## Setup" {{SETUP_RESULT}}; "## Install" {{INSTALL_RESULT}}; "## Launch" {{LAUNCH_RESULT}}; "## Screens captured" {{SCREENSHOT_LIST}} (numbered, file names only); "## Flows" (Flow file {{FLOW_FILE}}, Steps {{FLOW_STEPS_PASSED}}/{{FLOW_STEPS_TOTAL}}, Detail {{FLOW_DETAIL}}); "## Logcat" (Verdict {{LOGCAT_VERDICT}}, Evidence file {{LOGCAT_FILE}}, First offending line {{LOGCAT_FIRST_LINE}}); "## Next action" {{NEXT_ACTION}}.
> CONSTRAINTS: exactly these placeholders, spelled exactly as above; no extra sections; under 60 lines.
> DONE = scripts/test-apk.sh can fill every placeholder from a real run with no leftover tokens.
> ```

### 38. `templates/flow-checklist.md`
**PURPOSE:** The human checklist for designing a new flow file — so flows get written completely the first time.
**DETAILS:** A fill-in checklist mirroring the walk-flows.sh step vocabulary (file 34): app identity, entry point, each main screen and how you know you're on it (assert_text), each critical action and its expected result, destructive actions to NEVER include (purchases, sends, deletes), login handling (test accounts only — never real credentials in a flow file, printed as a warning at the top).
> **BUILD PROMPT:**
> ```
> Write templates/flow-checklist.md for "MuseAi-Skill-apk-testing" — a checklist a human completes before writing a new flow JSON.
> CONTENT: top warning box: "Never put real credentials in a flow file. Test accounts only. Never include steps that buy, send, post, or delete."; then checkbox sections: App (package, launcher activity, version); Entry (first screen, how you recognize it — the assert_text string); Main screens (one row each: name, how to reach it, assert_text); Critical actions (action, expected visible result); Switching/navigation (back behavior, tab/switch gestures); Sign-off (flow file name, author, date, tested against which AVD).
> DONE = completing this checklist gives walk-flows.sh's flow author every value the JSON needs, with the safety warning impossible to miss.
> ```

---

## EXAMPLES & OUTPUT

### 39. `examples/muse-number-three.flow.json`
**PURPOSE:** The first real flow — Muse Number 3's live isolation test (D6), shipped as the worked example.
**DETAILS:** Flow for package `com.fedos.musenumberthree`. Exactly **16 steps**, in this order: launch → wait 5 → screenshot "slot-1" → assert_foreground → swipe left (on the switcher area) → wait 2 → screenshot "slot-2" → swipe left → wait 2 → screenshot "slot-3" → swipe right → wait 2 → screenshot "back-to-slot-2" → key BACK behavior check → wait 1 → assert_foreground. This is the canonical count — §40's sample report states the same 16 steps ("steps 16/16"), and the isolation note is NOT a JSON step (see the header rule in the prompt below), so 16 is always true. The login-separation part is expressed as assertions + a documented manual checkpoint in sample-report.md: the automated flow proves slots open + switching works; the 3-logins-stay-separate proof is the screenshots of 3 different logged-in sessions side by side, reviewed by a human/agent eye — the flow must say so honestly, never claim an automated login check it doesn't do. Coordinates target the config AVD screen (D4/walk-flows constraints).
> **BUILD PROMPT:**
> ```
> Write examples/muse-number-three.flow.json — a flow file for scripts/walk-flows.sh (vocabulary: launch, wait, tap, swipe, key, type, screenshot, assert_foreground, assert_text — no others).
> TARGET: package com.fedos.musenumberthree (Muse Number 3: 3 Muse WebView slots, one visible, swipe/tap switching, separate login per slot).
> STEPS IN ORDER: launch the package; wait 5; screenshot "slot-1"; assert_foreground com.fedos.musenumberthree; swipe left; wait 2; screenshot "slot-2"; swipe left; wait 2; screenshot "slot-3"; swipe right; wait 2; screenshot "back-to-slot-2"; key BACK; wait 1; assert_foreground com.fedos.musenumberthree.
> HEADER COMMENT RULE: JSON has no comments, and the note is NEVER a JSON step (a note step would throw the count off — this flow is always exactly the 16 steps above). The isolation note goes in examples/sample-report.md only, exactly this text: "Login isolation is proven by the slot-1/2/3 screenshots showing 3 different sessions, reviewed visually. This flow proves slots open + switching works; it does not automate logins." The JSON stays pure steps.
> CONSTRAINTS: valid JSON, steps as an ordered array under a top-level "steps" key, plus top-level "name": "muse-number-three" and "package": "com.fedos.musenumberthree".
> DONE = walk-flows.sh runs it unchanged against the real APK, and its screenshots let a reviewer confirm 3 separate slots.
> ```

### 40. `examples/sample-report.md`
**PURPOSE:** A filled-in example report — what "good" looks like before anyone runs anything.
**DETAILS:** templates/test-report.md filled with the Muse Number 3 worked example (package com.fedos.musenumberthree, Actions run 39981992531 noted, clearly marked SAMPLE / NOT A REAL RUN at the top — this APK has only been static-tested so far; faking a live result here would break D2). Shows realistic screenshot lists, a CLEAN logcat verdict line, and a PASS-shaped layout, so the first real report can be compared against it.
> **BUILD PROMPT:**
> ```
> Write examples/sample-report.md by filling templates/test-report.md with a worked example for Muse Number 3.
> VALUES: Package com.fedos.musenumberthree; APK file "MuseAi-Number-3-debug.apk (GitHub Actions run 39981992531)"; Version 0.1.0-debug; SHA-256 "SAMPLE — replaced by the real hash in a real report"; AVD apk-tester-phone; System image system-images;android-34;google_apis;x86_64; Screens: 01-launch.png, 02-scroll-down.png, 03-scroll-up.png + flow shots slot-1/slot-2/slot-3/back-to-slot-2; Flow examples/muse-number-three.flow.json, steps 16/16; Logcat CLEAN; Verdict PASS (sample-shaped); Next action "Compare the slot-1/2/3 screenshots — 3 different logged-in sessions confirm isolation."
> TOP OF FILE, before the title, exactly: "> SAMPLE — format example only. This is NOT a real test run. The Muse Number 3 APK has been static-tested only; no live run has happened yet."
> DONE = the sample teaches the report shape perfectly while being impossible to mistake for a real result.
> ```

### 41. `output/reports/.gitkeep`
**PURPOSE:** Keeps the reports directory in the repo while real reports stay uncommitted (D8).
**DETAILS:** Empty file (single newline at most). The directory itself is the contract: test-apk.sh writes `<package>-<timestamp>.md` + the logcat evidence file here, per config `report_dir`.
> **BUILD PROMPT:**
> ```
> Create output/reports/.gitkeep as an empty file.
> DONE = the file exists, is empty, and output/reports/ is tracked in git while *.md reports inside it are ignored by the root .gitignore.
> ```

### 42. `output/screenshots/.gitkeep`
**PURPOSE:** Keeps the screenshots directory in the repo while real screenshots stay uncommitted (D8).
**DETAILS:** Empty file. Screenshots land here per config `screenshot_dir`, in per-run subfolders named by timestamp, produced only via scripts/capture-screen.sh.
> **BUILD PROMPT:**
> ```
> Create output/screenshots/.gitkeep as an empty file.
> DONE = the file exists, is empty, and output/screenshots/ is tracked in git while *.png screenshots inside it are ignored by the root .gitignore.
> ```

---

## PROMPTS — ADDENDUM

### 43. `prompts/README-PROMPT.md`
**PURPOSE:** The standalone copy-paste prompt that transforms the repo's README.md into a polished, memorable project landing page — a visitor should want to try the project within 30 seconds.
**DETAILS:** Prompt supplied verbatim by Git-FED, 2026-10-23 ~13:57 EDT ("add these prompts"). Binding rules inside it: inspect the repo first, find the real entry point / quickest working demo, check for a live demo + GitHub Pages, NEVER invent features, links, metrics, users, integrations, screenshots, or deployment status; demo GIF/screenshots must be REAL (actual app, ~30 seconds, saved as `assets/demo/demo.gif`) or clearly labeled unavailable — no fake mockups, no placeholder screenshots. README structure it mandates: name + one-line plain-English description, true badges only, "Why this exists", "See it work", "Screenshots" (2–4 real), "Quick start". Text as received ends at the Quick start install/run/test block — filed exactly as received, nothing invented past that point. This prompt, when run, is the authority for README.md's final shape; file 1's prompt is the summary version.
> **BUILD PROMPT:**
> ```
> Write prompts/README-PROMPT.md containing, verbatim, the README transformation prompt below — Git-FED's exact text, unchanged, including where it ends:
>
> ---
> Transform this repository’s README.md into a polished, memorable project landing page that makes someone want to try the project within 30 seconds.
>
> First inspect the repository carefully:
>
> Identify what the project actually does.
> Find the real entry point and quickest working demo.
> Inspect package files, scripts, workflows, documentation, screenshots, assets, examples, and deployment configuration.
> Check whether a live demo already exists.
> Check whether GitHub Pages or another static deployment can be enabled.
> Find the most useful real examples a visitor can run immediately.
> Do not invent features, links, metrics, users, integrations, screenshots, or deployment status.
> If something is missing, create it when possible or clearly label it as unavailable.
> Then redesign README.md using this structure:
>
> [Project Name]
> Start with a concise one-line description that explains the project in plain English.
>
> Add a small badge row only for badges that are true and useful, such as:
>
> License
> Build status
> Live demo
> Documentation
> Version
> Package status
> Why this exists
> Lead with the real problem.
>
> Explain:
>
> What is frustrating, confusing, slow, risky, or repetitive today.
> Who experiences that problem.
> What this project makes easier.
> Why the project is intentionally different.
> Use short paragraphs and direct language. Avoid vague startup language and unnecessary technical jargon.
>
> See it work
> Make the fastest path obvious.
>
> Include, in this order when available:
>
> A live demo link.
> A short demo GIF or video.
> A minimal quick-start command.
> A link to the main example.
> The reader should be able to understand the project without reading the entire repository.
>
> If no demo asset exists but the project can run locally:
>
> Create a short, real screen recording or animated GIF.
> Use the actual application.
> Show the most important workflow in roughly 30 seconds.
> Save it under a clear path such as assets/demo/demo.gif.
> Do not create a fake product mockup and present it as the working app.
> Screenshots
> Add 2–4 real screenshots of the application or command-line output in action.
>
> Use descriptive filenames and accessible alt text.
>
> Prefer screenshots that show:
>
> The main workflow.
> A meaningful result.
> A useful edge case.
> The project’s visual personality.
> Do not use placeholder screenshots.
>
> Quick start
> Show the shortest reliable setup:
>
> # install
> ...
>
> # run
> ...
>
> # test
> ...
> ---
> DONE = prompts/README-PROMPT.md contains the prompt above byte-for-byte, and file 1 (README.md) is always produced by running it against the real repo — never by inventing demo assets or deployment status.
> ```

### 44. `prompts/EMAIL-LIST-PROMPT.md`
**PURPOSE:** The copy-paste prompt for the FedPromptly "Join Email List" component — Discord-style invite widget + Supabase auth modal — embedded in index.html as section 5.
**DETAILS:** Full standalone HTML supplied verbatim by Git-FED, 2026-10-23 ~13:58 EDT (title "FEDPromptly · Join Email List"; the supplied text in this chat's transcript is the source of truth for byte-for-byte code). When embedding into index.html: extract widget + modal + styles + script only (never nest a second `<html>` document), scope the styles under a wrapper class (the 2026-10-20 integration scoped them under `.fed-auth`) so they cannot break the host page, and keep every element ID exactly once. Functional spec, all of it binding:
- **Widget** (`.discord-invite-widget`, id `openSignupBtn`, role=button, keyboard Enter/Space opens): green status dot (`statusDot`, glow #23a55a) + status text (`statusText`, "Join now" / "Signed in" when logged in), fake readonly email input (`emailInput`) with a TYPEWRITER placeholder cycling exactly these phrases: "Type your email here…", "Join our newsletter…", "Get early access…", "Stay in the loop…" (type 65 ms/char, delete 30 ms/char, hold 1600 ms, 350 ms between, "|" cursor). Hint under it: "Click to join our email list".
- **Modal** (`authModal` overlay, `.modal-card`, close ×, click-outside + Escape close): title "Join Email List", sub "Stay updated with FEDPromptly". Form (`loginForm`): Email (`loginEmail`), Password (`loginPassword`, minlength 6), "Forgot password?" link, primary submit (`authSubmitBtn`, "Join Email List" / "Sign In"), message area (`authMessage`: error/success/info styles). Divider "or" + toggle (`toggleAuthMode` / `toggleText`): join ⇄ sign in ("Already joined? Sign In" / "New here? Join Email List").
- **Backend — Supabase, exact values, do not substitute:** library `https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2`; URL `https://qyuczfpgydgqywgthgrz.supabase.co`; publishable (client-side, public) key `sb_publishable_2NLEuDREplLS9DgUXeA8Tw_f8MJOhCq`. Calls: `auth.signUp` (emailRedirectTo = current page), `auth.signInWithPassword`, `auth.resetPasswordForEmail` (redirectTo = current page), `auth.signOut`, `auth.getSession` on load, `auth.onAuthStateChange` sync. Handle the named cases: already-registered (identities length 0 / "User already registered"), email-not-confirmed, invalid credentials — with the friendly messages from the supplied code.
- **Logged-in view** (`loggedInView`): gradient avatar with the email's first initial (`loggedInAvatar`), name = email prefix (`loggedInName`), email (`loggedInEmail`), thank-you box — "Thank you for joining our email list!" + "We will be reaching out soon… email me anytime: contact@fedpromptly.com" (mailto) — and a Logout button (`logoutBtn`).
- **Look:** Inter font, dark theme vars from the supplied code (--bg-body #0b0b10, --bg-card #14141e, --bg-input #1e1e2f, purple gradient #7c5cfc→#a78bfa), pill primary button, modal radius 1.5rem, blur backdrop. Widget look deliberately mirrors a Discord invite (#2b2d31 card, #5865F2 hover ring).
> **BUILD PROMPT:**
> ```
> Write prompts/EMAIL-LIST-PROMPT.md — the generation prompt for the FedPromptly "Join Email List" component, reproducing the component Git-FED supplied on 2026-10-23 (full standalone HTML, "FEDPromptly · Join Email List") as the reference implementation.
> The prompt inside must instruct the builder to: (1) embed ONLY the widget + modal + styles + script into the target page (never a nested <html> document), with styles scoped under a wrapper class so nothing leaks into or out of the host page, and every element ID present exactly once; (2) use the exact Supabase project values: URL https://qyuczfpgydgqywgthgrz.supabase.co, publishable key sb_publishable_2NLEuDREplLS9DgUXeA8Tw_f8MJOhCq, supabase-js@2 CDN; (3) keep the widget behavior (Discord-style card, green status dot, "Join now"/"Signed in" states, typewriter placeholder with the 4 exact phrases and the supplied timings); (4) keep the full auth behavior (join/sign-in toggle, forgot password, already-registered + not-confirmed + invalid-credentials messages, session check on load, onAuthStateChange sync, logged-in thank-you view with the contact@fedpromptly.com mailto and Logout); (5) keep the supplied dark/purple Inter styling.
> DONE = a page built from this prompt has a working Join Email List widget + modal indistinguishable in look and behavior from Git-FED's supplied HTML, creating accounts on the same Supabase project.
> ```

### 45. `prompts/PROMO-CODES-PROMPT.md`
**PURPOSE:** The copy-paste prompt for the promo codes section of index.html (section 7) — Git-FED's three referral/invite offers, word-for-word.
**DETAILS:** Supplied verbatim by Git-FED, 2026-10-23 ~14:00 EDT ("promo code prompts"). Three blocks, in his order, NEVER reworded, shortened, or merged — the Muse block is his standing promo block (law since 2026-10-06, code on every post):
1. **Muse** — "Check out Muse, your personal AI agent. Redeem my code in Settings within 48 hours of joining and we'll both get 1 billion Muse tokens." Code: **5F2V31** — https://muse.ai/join
2. **Manus AI** — "Manus Ai Invite Code: **G3ADN**" (no link supplied — do NOT invent one)
3. **Teamily** — "Join me on Teamily, the human-agent platform, where you and always-on agents get work done together in one unified and context-aware space. Redeem my code in Settings - Credits Center and you'll get 5 CREDITS right away." Code: **2U6Q8D** — https://teamily.ai/i/2U6Q8D
Presentation: one card per offer on index.html, the code itself big + monospace + copy-friendly, redeem instructions exactly as written above. If a code ever changes, this file changes in the same edit — a dead code on a live page is a defect.
> **BUILD PROMPT:**
> ```
> Write prompts/PROMO-CODES-PROMPT.md — the generation prompt for a "Promo Codes" section, containing these three offers verbatim and instructing the builder to render one card per offer with the code big, monospace, and copy-friendly, the redeem instructions unaltered, and links exactly as given (Manus gets NO link — none was supplied):
> (1) "Check out Muse, your personal AI agent. Redeem my code in Settings within 48 hours of joining and we'll both get 1 billion Muse tokens. Code: 5F2V31 https://muse.ai/join"
> (2) "Manus Ai Invite Code: G3ADN"
> (3) "Join me on Teamily, the human-agent platform, where you and always-on agents get work done together in one unified and context-aware space. Redeem my code in Settings - Credits Center and you'll get 5 CREDITS right away. Code: 2U6Q8D https://teamily.ai/i/2U6Q8D"
> CONSTRAINT for the prompt: never reword, shorten, reorder, or add offers; a code change updates this file first, then every page using it.
> DONE = the section built from this prompt shows exactly the 3 offers above, word-for-word, codes 5F2V31 / G3ADN / 2U6Q8D.
> ```

---

## Build order
1. `docs/ultimate-file-tree.md` (file 20) + `docs/DECISIONS.md` (21) — the contract first.
2. Root: `.gitignore` (5), `LICENSE` (4), `CHANGELOG.md` (6).
3. `config/tester.config.json` (19) — every later file references it.
4. `SKILL.md` (2) + `README.md` (1).
5. Templates: `templates/test-report.md` (37), `templates/flow-checklist.md` (38).
6. Scripts, bottom-up: `scripts/capture-screen.sh` (35), `scripts/logcat-check.sh` (33), `scripts/launch-and-capture.sh` (32), `scripts/walk-flows.sh` (34), `scripts/cleanup.sh` (36), then `scripts/test-apk.sh` (31).
7. Setup scripts (WRITE only — running them is the owner's go, D1): `setup/install-sdk.sh` (28), `setup/create-avd.sh` (29), `setup/verify-setup.sh` (30).
8. Examples: `examples/muse-number-three.flow.json` (39), `examples/sample-report.md` (40).
9. Assets: `assets/icon-source.svg` (9), `assets/icon.png` (8), `assets/og-image.png` (10), `assets/favicon/` set (11–18).
10. `index.html` (3) — last, because it references the assets, the report shape, and the footer + payment prompts below.
11. Docs for humans: `docs/SETUP.md` (22), `docs/USAGE.md` (23), `docs/TROUBLESHOOTING.md` (24).
12. Prompts + CI: `prompts/BUILD-PROMPT.md` (25), `prompts/HTML-PROMPT.md` (26), `prompts/ICON-PROMPT.md` (27), `prompts/README-PROMPT.md` (43), `prompts/EMAIL-LIST-PROMPT.md` (44), `prompts/PROMO-CODES-PROMPT.md` (45), `.github/workflows/lint.yml` (7).
13. Output placeholders: files 41–42. Then Git-FED creates/pushes the repo himself (GitHub zero-writes for Muse3) and, only on his separate go, setup runs.

---

## FOOTER PROMPT (standalone — the footer for index.html, file 3, step 8)

```
Build the footer for index.html ("APK Tester Skill") using the FED-OS public footer layout. Four columns, public links only, exactly this content — no additions, no substitutions:

COLUMN 1 — FED-OS:
- Explore the Ecosystem: https://www.fedpromptly.org
- Join FED-OS Membership: https://www.fedpromptly.com/aid
- Storefront: https://www.jabburr.com/fed-os
- Whop: https://whop.com/fedpromptly/

COLUMN 2 — Contact:
- General: contact@fedpromptly.com (mailto)
- Support: support@fedpromptly.com (mailto)
- Business: business@fedpromptly.com (mailto)
- Careers: careers@fedpromptly.com (mailto)

COLUMN 3 — Media:
- Articles: https://substack.com/@fedpromptly
- Blog Post: https://fedpromptly.wordpress.com/
- GitFed Blog: https://gitfed.substack.com/
- Artwork: https://www.deviantart.com/fedpromptly
- Social Media: https://bsky.app/profile/fed-os.bsky.social
- Advertisement / X: https://x.com/Fedpromptly
(Facebook https://facebook.com/fedpromptly is SKIPPED — it is not in the recommended public footer.)

COLUMN 4 — Support:
- Supporters: https://www.patreon.com/c/FEDpromptly
- Tips / Donations: https://buymeacoffee.com/fedpromptly
- Developers: https://discord.gg/Jm4XStx4Pf

VISIBILITY RULES (binding):
- Public = footer OK. Premium/Member = footer OK as a teaser landing page only (membership, Whop, Patreon tiers — link the landing page, never the paid content itself).
- Private/Restricted and Internal = NEVER in the footer.
- DO NOT put the Private Matrix link (https://matrix.to/#/#fed-os:matrix.org) in this footer. It is 18+ and country-locked (Canada, Switzerland, Russia, Iran, Somalia, Turkmenistan only) and belongs behind a gated "Private Communities" page: 18+ warning -> checkbox confirmation -> country eligibility check -> then reveal the link.
- DO NOT put the Personal Substack (https://substack.com/@gitfed) in this footer — author bio / personal page only.
- Gated things that stay out of public navigation entirely: FED-OS member dashboard, Whop paid products, Patreon premium tiers, Discord private channels, the Private Matrix room.

STYLE: match index.html (dark theme, accent color), 4 columns on desktop stacking to 1 on mobile, column headings exactly "FED-OS", "Contact", "Media", "Support", small bottom line under the columns: "APK Tester Skill by Git-FED — FedPromptly".
DONE = the footer contains the 17 links/emails above and nothing else — no Matrix, no personal Substack, no Facebook.
```

---

## Status
SPEC ONLY — written 2026-10-23 on Git-FED's order ("full file tree with prompts"; index.html, age-gated payment embeds, and the FED-OS footer prompt added by him same day). Nothing installed, nothing built, nothing pushed. The build starts only on Git-FED's separate go, and the SDK/emulator setup runs only on his go after that (D1).
