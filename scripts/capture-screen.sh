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
if [[ $# -ne 1 ]]; then echo "Usage: $0 <output.png>" >&2; exit 2; fi
OUT="$1"; mkdir -p "$(dirname "$OUT")"; TMP="${OUT}.tmp.png"
if ! "$ADB" exec-out screencap -p > "$TMP" 2>/dev/null || [[ ! -s "$TMP" ]]; then
  rm -f "$TMP"; DEVICE="/sdcard/capture-screen-$$.png"
  "$ADB" shell screencap -p "$DEVICE" >/dev/null && "$ADB" pull "$DEVICE" "$TMP" >/dev/null && "$ADB" shell rm -f "$DEVICE" >/dev/null || true
fi
if [[ ! -s "$TMP" ]]; then rm -f "$TMP"; echo "Unable to capture screenshot" >&2; exit 1; fi
mv "$TMP" "$OUT"; SIZE=$(wc -c < "$OUT" | tr -d ' ')
if (( SIZE < 10240 )); then echo "WARNING: screenshot suspiciously small ($OUT) - possible black/secure screen" >&2; fi
printf '%s (%s bytes)\n' "$OUT" "$SIZE"
