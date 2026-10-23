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
if [[ $# -ne 2 ]]; then echo "Usage: $0 <package> <output-file>" >&2; exit 2; fi
PKG="$1"; OUT="$2"; N="$(read_cfg logcat_lines)"; mkdir -p "$(dirname "$OUT")"
DUMP=$(mktemp); MATCH=$(mktemp); trap 'rm -f "$DUMP" "$MATCH"' EXIT
"$ADB" logcat -d -t "$N" > "$DUMP"
grep -E "$PKG|AndroidRuntime" "$DUMP" > "$OUT" || true
if [[ ! -s "$OUT" ]]; then echo "LOGCAT: EMPTY (suspicious)"; exit 1; fi
# Match only the specified case-sensitive fatal markers; package-specific ANR/process lines are exact patterns.
grep -F 'FATAL EXCEPTION' "$OUT" >> "$MATCH" || true
grep -F 'AndroidRuntime' "$OUT" >> "$MATCH" || true
grep -F "Process $PKG has died" "$OUT" >> "$MATCH" || true
grep -F "ANR in $PKG" "$OUT" >> "$MATCH" || true
grep -F 'signal 11 (SIGSEGV)' "$OUT" >> "$MATCH" || true
if [[ -s "$MATCH" ]]; then echo "LOGCAT: CRASH"; head -n 1 "$MATCH"; exit 1; fi
echo "LOGCAT: CLEAN"; exit 0
