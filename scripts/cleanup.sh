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
if [[ $# -ne 2 ]]; then echo "Usage: $0 <package> <booted-by-us:true|false>" >&2; exit 2; fi
PKG="$1"; BOOTED="$2"; [[ "$BOOTED" == true || "$BOOTED" == false ]] || { echo "booted flag must be true or false" >&2; exit 2; }
"$ADB" shell pm clear "$PKG" >/dev/null 2>&1 || true; echo "cleared app data: $PKG"
"$ADB" uninstall "$PKG" >/dev/null 2>&1 || true; echo "uninstalled tested package if present: $PKG"
if [[ "$BOOTED" == true ]]; then
  "$ADB" emu kill >/dev/null 2>&1 || true
  for _ in $(seq 1 30); do "$ADB" devices 2>/dev/null | grep -q "$ANDROID_SERIAL" || break; sleep 1; done
  echo "stopped emulator started by this run: $ANDROID_SERIAL"
else echo "left pre-existing emulator running: $ANDROID_SERIAL"; fi
echo "cleanup done: removed tested app data/package; no reports or screenshots touched"
