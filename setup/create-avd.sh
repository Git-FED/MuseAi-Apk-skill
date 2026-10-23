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
AVD="$(read_cfg avd_name)"; IMAGE="$(read_cfg system_image)"
if "$EMULATOR" -list-avds | grep -Fxq "$AVD"; then echo "AVD already exists: $AVD"; exit 0; fi
if [[ ! -d "$SDK_ROOT/$IMAGE" ]]; then echo "System image missing: $IMAGE. Run setup/install-sdk.sh and see docs/SETUP.md" >&2; exit 2; fi
printf 'no\n' | "$SDK_ROOT/cmdline-tools/latest/bin/avdmanager" create avd --force --name "$AVD" --package "$IMAGE" --device pixel_6
"$EMULATOR" -list-avds
