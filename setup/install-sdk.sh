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
# The only download source: official Android command-line tools archive.
CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
SDKMANAGER="$SDK_ROOT/cmdline-tools/latest/bin/sdkmanager"
if [[ ! -x "$SDKMANAGER" ]]; then
  echo "Downloading official Android command-line tools: $CMDLINE_TOOLS_URL"
  mkdir -p "$SDK_ROOT/cmdline-tools/latest"; TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
  curl --fail --location --show-error "$CMDLINE_TOOLS_URL" -o "$TMP/tools.zip"
  unzip -q "$TMP/tools.zip" -d "$TMP/unpacked"
  cp -a "$TMP/unpacked/cmdline-tools/." "$SDK_ROOT/cmdline-tools/latest/"
else echo "Command-line tools already present; skipping download"; fi
SDKMANAGER="$SDK_ROOT/cmdline-tools/latest/bin/sdkmanager"
[[ -x "$SDKMANAGER" ]] || { echo "sdkmanager missing after extraction" >&2; exit 2; }
echo "Accepting Android SDK licenses"; yes | "$SDKMANAGER" --sdk_root="$SDK_ROOT" --licenses >/dev/null || true
IMAGE="$(read_cfg system_image)"
for pkg in platform-tools emulator "$IMAGE"; do
  if [[ "$pkg" == system-images\;* ]]; then
    image_dir="$SDK_ROOT/${pkg//\;/\/}"
  else image_dir="$SDK_ROOT/$pkg"; fi
  if [[ -d "$image_dir" ]]; then echo "Already installed: $pkg"; else echo "Installing: $pkg"; "$SDKMANAGER" --sdk_root="$SDK_ROOT" "$pkg"; fi
done
"$SDK_ROOT/platform-tools/adb" --version
"$SDK_ROOT/emulator/emulator" -version
