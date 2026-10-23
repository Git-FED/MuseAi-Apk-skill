# Master build prompt

You are building `MuseAi-Skill-apk-testing` from the repository contract.

1. Read `docs/ultimate-file-tree.md` and `docs/DECISIONS.md` first.
2. Build files in the contract's **Build order**, one at a time, using each file's own BUILD PROMPT.
3. After each file, verify it against that file's DONE line before continuing.
4. NEVER run `setup/install-sdk.sh` or `setup/create-avd.sh` (the SDK download requires the owner's explicit go); never run a test and never push to GitHub.
5. If a prompt and the spec disagree, stop and report it; the spec wins.
6. Do not commit generated APKs, reports, screenshots, SDK files, or AVD data.

This prompt authorizes file-writing only; it does not authorize downloads, installs, emulator startup, tests, or GitHub writes.
