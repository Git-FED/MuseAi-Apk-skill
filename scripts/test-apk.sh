#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="$ROOT/config/tester.config.json"
read_cfg() { python3 - "$CONFIG" "$1" <<'PYCFG'
import json,sys,os
with open(sys.argv[1],encoding="utf-8") as f: d=json.load(f)
v=d[sys.argv[2]]
if sys.argv[2]=="sdk_root": v=os.path.expanduser(v)
print(v)
PYCFG
}
SDK_ROOT="$(read_cfg sdk_root)"
ADB="$SDK_ROOT/platform-tools/adb"
EMULATOR="$SDK_ROOT/emulator/emulator"
PORT="$(read_cfg emulator_port)"
export PATH="$SDK_ROOT/platform-tools:$SDK_ROOT/emulator:$PATH"
export ANDROID_SERIAL="emulator-$PORT"
if [[ $# -lt 1 || $# -gt 2 ]]; then echo "Usage: $0 <apk> [flow.json]" >&2; exit 2; fi
APK="$(realpath "$1" 2>/dev/null || true)"; [[ -f "$APK" ]] || { echo "Setup error: APK file not found" >&2; exit 2; }
FLOW="${2:-$(read_cfg default_flow)}"; [[ "$FLOW" = /* ]] || FLOW="$ROOT/$FLOW"
[[ -f "$FLOW" ]] || { echo "Setup error: flow file not found: $FLOW" >&2; exit 2; }
python3 -m json.tool "$CONFIG" >/dev/null || { echo "Setup error: invalid config" >&2; exit 2; }
AVD="$(read_cfg avd_name)"; IMAGE="$(read_cfg system_image)"; TIMEOUT="$(read_cfg boot_timeout_seconds)"; SD="$(read_cfg screenshot_dir)"; RD="$(read_cfg report_dir)"
[[ -x "$ADB" && -x "$EMULATOR" ]] || { echo "Setup error: SDK adb/emulator missing; see docs/SETUP.md" >&2; exit 2; }
"$EMULATOR" -list-avds | grep -Fxq "$AVD" || { echo "Setup error: configured AVD missing: $AVD" >&2; exit 2; }
mkdir -p "$ROOT/$SD" "$ROOT/$RD"; TS=$(date -u +%Y%m%dT%H%M%SZ); RUN_DIR="$ROOT/$SD/$TS"; mkdir -p "$RUN_DIR"
SHA=$(sha256sum "$APK" | awk '{print $1}'); BASE=$(basename "$APK"); PKG="unknown"; VERSION="unknown"; VERDICT=PASS; SETUP_RESULT="PASS"; INSTALL_RESULT="NOT RUN"; LAUNCH_RESULT="NOT RUN"; FLOW_OUT="NOT RUN"; LOGCAT_VERDICT="NOT RUN"; FIRST="none"; FLOW_P="0"; FLOW_T="0"; BOOTED=false; SETUP_RC=0; REPORT="$ROOT/$RD/unknown-$TS.md"; LOGFILE="$ROOT/$RD/logcat-unknown-$TS.txt"
# Prefer Android SDK's analyzer/aapt, then inspect package-manager metadata where possible.
if [[ -x "$SDK_ROOT/cmdline-tools/latest/bin/apkanalyzer" ]]; then PKG=$("$SDK_ROOT/cmdline-tools/latest/bin/apkanalyzer" manifest application-id "$APK" 2>/dev/null || echo unknown); VERSION=$("$SDK_ROOT/cmdline-tools/latest/bin/apkanalyzer" manifest version-name "$APK" 2>/dev/null || echo unknown); elif [[ -x "$SDK_ROOT/build-tools/$(ls "$SDK_ROOT/build-tools" 2>/dev/null | sort -V | tail -1)/aapt" ]]; then AAPT="$SDK_ROOT/build-tools/$(ls "$SDK_ROOT/build-tools" | sort -V | tail -1)/aapt"; PKG=$("$AAPT" dump badging "$APK" | sed -n "s/^package: name='\([^']*\)'.*/\1/p" | head -n1); VERSION=$("$AAPT" dump badging "$APK" | sed -n "s/^package:.*versionName='\([^']*\)'.*/\1/p" | head -n1); fi
[[ -n "$PKG" ]] || PKG=unknown; [[ -n "$VERSION" ]] || VERSION=unknown
REPORT="$ROOT/$RD/$PKG-$TS.md"; LOGFILE="$ROOT/$RD/logcat-$PKG-$TS.txt"
if "$ADB" devices | grep -q "$ANDROID_SERIAL.*device"; then :; else "$EMULATOR" -avd "$AVD" -port "$PORT" -no-window -no-audio -no-snapshot-save >/tmp/apk-tester-emulator.log 2>&1 & BOOTED=true; fi
END=$((SECONDS+TIMEOUT)); until "$ADB" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r' | grep -q '^1$'; do if (( SECONDS >= END )); then SETUP_RESULT="FAIL: emulator boot timeout"; VERDICT=FAIL; SETUP_RC=2; break; fi; sleep 2; done
if [[ "$SETUP_RESULT" == PASS ]]; then "$ADB" logcat -c || true
 if "$ADB" install -r "$APK" >"$RUN_DIR/install.txt" 2>&1; then INSTALL_RESULT=PASS; else INSTALL_RESULT="FAIL: $(tail -n 3 "$RUN_DIR/install.txt" | tr '\n' ' ')"; VERDICT=FAIL; fi
 if [[ "$INSTALL_RESULT" == PASS && "$PKG" != unknown ]]; then
   if "$ROOT/scripts/launch-and-capture.sh" "$PKG" "$RUN_DIR"; then LAUNCH_RESULT=PASS; else LAUNCH_RESULT=FAIL; VERDICT=FAIL; fi
   set +e; "$ROOT/scripts/walk-flows.sh" "$FLOW" "$RUN_DIR" >"$RUN_DIR/flow.txt" 2>&1; FLOW_RC=$?; set -e
   FLOW_OUT=$(cat "$RUN_DIR/flow.txt"); if [[ $FLOW_RC -ne 0 ]]; then VERDICT=FAIL; fi
   FLOW_T=$(python3 -c 'import json,sys;print(len(json.load(open(sys.argv[1]))["steps"]))' "$FLOW" 2>/dev/null || echo 0); if [[ $FLOW_OUT =~ PASS\ \(([0-9]+)/([0-9]+)\ steps\) ]]; then FLOW_P=${BASH_REMATCH[1]}; FLOW_T=${BASH_REMATCH[2]}; fi
   set +e; "$ROOT/scripts/logcat-check.sh" "$PKG" "$LOGFILE" >"$RUN_DIR/logcat-verdict.txt" 2>&1; LRC=$?; set -e
   LOGCAT_VERDICT=$(head -n1 "$RUN_DIR/logcat-verdict.txt"); [[ $LRC -eq 0 ]] || VERDICT=FAIL; FIRST=$(sed -n '2p' "$RUN_DIR/logcat-verdict.txt"); [[ -n "$FIRST" ]] || FIRST=none
 else [[ "$PKG" == unknown ]] && { LAUNCH_RESULT="FAIL: package identity unavailable"; VERDICT=FAIL; }
 fi
fi
SCREENS=$(find "$RUN_DIR" -maxdepth 1 -name '*.png' -printf '%f\n' | sort | sed 's/^/- /' || true); COUNT=$(find "$RUN_DIR" -maxdepth 1 -name '*.png' | wc -l | tr -d ' '); [[ -n "$SCREENS" ]] || SCREENS='- None captured'
[[ "$COUNT" -gt 0 ]] || VERDICT=FAIL
[[ "$LOGCAT_VERDICT" == 'LOGCAT: CLEAN' ]] || VERDICT=FAIL
NEXT='Review the attached screenshots and logcat evidence before sharing this result.'; [[ "$VERDICT" == PASS ]] || NEXT='Treat as FAIL; inspect the exact failed step and evidence, fix the cause, then rerun.'
# Fill report placeholders without shell-unsafe interpolation.
python3 - "$ROOT/templates/test-report.md" "$REPORT" "$PKG" "$TS" "$BASE" "$VERSION" "$SHA" "$AVD" "$IMAGE" "$VERDICT" "$SETUP_RESULT" "$INSTALL_RESULT" "$LAUNCH_RESULT" "$SCREENS" "$FLOW" "$FLOW_P" "$FLOW_T" "$FLOW_OUT" "$LOGCAT_VERDICT" "$(basename "$LOGFILE")" "$FIRST" "$NEXT" <<'PY'
from pathlib import Path
import sys
keys=['PACKAGE','TIMESTAMP','APK_FILE','VERSION','SHA256','AVD_NAME','SYSTEM_IMAGE','VERDICT','SETUP_RESULT','INSTALL_RESULT','LAUNCH_RESULT','SCREENSHOT_LIST','FLOW_FILE','FLOW_STEPS_PASSED','FLOW_STEPS_TOTAL','FLOW_DETAIL','LOGCAT_VERDICT','LOGCAT_FILE','LOGCAT_FIRST_LINE','NEXT_ACTION']
t=Path(sys.argv[1]).read_text(); out=Path(sys.argv[2]); vals=sys.argv[3:]
for k,v in zip(keys,vals): t=t.replace('{{'+k+'}}',v)
out.write_text(t)
PY
"$ROOT/scripts/cleanup.sh" "$PKG" "$BOOTED" >/dev/null 2>&1 || true
printf 'Report: %s\nScreenshots: %s (%s)\n' "$REPORT" "$COUNT" "$RUN_DIR"
if [[ "$SETUP_RC" -eq 2 ]]; then exit 2; fi
[[ "$VERDICT" == PASS ]] && exit 0 || exit 1
