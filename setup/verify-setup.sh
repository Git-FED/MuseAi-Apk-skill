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
AVD="$(read_cfg avd_name)"; TIMEOUT="$(read_cfg boot_timeout_seconds)"; FAIL=0; STARTED=0
shutdown(){ if [[ "$STARTED" == 1 ]]; then "$ADB" emu kill >/dev/null 2>&1 || true; fi; }
trap shutdown EXIT
check(){ if "$@"; then echo "PASS: $1"; else echo "FAIL: $1"; FAIL=1; fi; }
if python3 -m json.tool "$CONFIG" >/dev/null; then echo "PASS: config parses"; else echo "FAIL: config parses"; exit 2; fi
if [[ -x "$ADB" ]] && "$ADB" --version >/dev/null 2>&1; then echo "PASS: adb version"; else echo "FAIL: adb version"; exit 2; fi
if [[ -x "$EMULATOR" ]]; then echo "PASS: emulator binary"; else echo "FAIL: emulator binary"; exit 2; fi
if "$EMULATOR" -list-avds | grep -Fxq "$AVD"; then echo "PASS: configured AVD exists"; else echo "FAIL: configured AVD exists"; exit 2; fi
if ! "$ADB" devices | grep -q "$ANDROID_SERIAL.*device"; then "$EMULATOR" -avd "$AVD" -port "$PORT" -no-window -no-audio -no-snapshot-save >/tmp/apk-tester-emulator.log 2>&1 & STARTED=1; fi
END=$((SECONDS+TIMEOUT)); BOOT=0
while (( SECONDS < END )); do if "$ADB" -s "$ANDROID_SERIAL" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r' | grep -q '^1$'; then BOOT=1; break; fi; sleep 2; done
if [[ "$BOOT" == 1 ]]; then echo "PASS: emulator boot completed"; else echo "FAIL: emulator boot completed"; FAIL=1; fi
if [[ "$BOOT" == 1 ]] && "$ADB" shell echo works 2>/dev/null | grep -q works; then echo "PASS: adb shell works"; else echo "FAIL: adb shell works"; FAIL=1; fi
if [[ "$STARTED" == 1 ]]; then shutdown; STARTED=0; echo "PASS: emulator shutdown"; else echo "PASS: emulator shutdown (not started by verifier)"; fi
if (( FAIL )); then echo "SETUP: FAIL"; exit 2; fi
echo "SETUP: PASS"
