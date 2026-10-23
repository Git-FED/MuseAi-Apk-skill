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
if [[ $# -ne 2 ]]; then echo "Usage: $0 <package> <screenshot-dir>" >&2; exit 2; fi
PKG="$1"; DIR="$2"; mkdir -p "$DIR"
ACTIVITY=$("$ADB" shell cmd package resolve-activity --brief "$PKG" 2>/dev/null | tr -d '\r' | tail -n 1 || true)
if [[ -n "$ACTIVITY" && "$ACTIVITY" == */* ]]; then "$ADB" shell am start -n "$ACTIVITY" >/dev/null; else "$ADB" shell monkey -p "$PKG" 1 >/dev/null; fi
sleep 3
FG=$("$ADB" shell dumpsys window 2>/dev/null | grep -E 'mCurrentFocus|mFocusedApp' | head -n 1 || true)
if [[ "$FG" != *"$PKG"* ]]; then echo "App not foreground after launch; foreground: ${FG:-unknown}" >&2; exit 1; fi
"$ROOT/scripts/capture-screen.sh" "$DIR/01-launch.png"
"$ADB" shell input swipe 540 1900 540 500 350; sleep 2
"$ROOT/scripts/capture-screen.sh" "$DIR/02-scroll-down.png"
"$ADB" shell input swipe 540 500 540 1900 350; sleep 2
"$ROOT/scripts/capture-screen.sh" "$DIR/03-scroll-up.png"
"$ADB" shell input keyevent 4; sleep 2
FG=$("$ADB" shell dumpsys window 2>/dev/null | grep -E 'mCurrentFocus|mFocusedApp' | head -n 1 || true)
if [[ "$FG" == *"$PKG"* ]]; then "$ROOT/scripts/capture-screen.sh" "$DIR/04-back.png"; fi
