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
if [[ $# -ne 2 ]]; then echo "Usage: $0 <flow.json> <screenshot-dir>" >&2; exit 2; fi
FLOW="$1"; DIR="$2"; mkdir -p "$DIR"
python3 - "$FLOW" <<'PY'
import json,sys
try:
 d=json.load(open(sys.argv[1],encoding='utf-8'))
 assert isinstance(d,dict) and isinstance(d.get('steps'),list) and d['steps'], 'flow must be an object with a non-empty steps array'
 allowed={'launch','wait','tap','swipe','key','type','screenshot','assert_foreground','assert_text'}
 for i,s in enumerate(d['steps'],1):
  assert isinstance(s,dict) and len(s)==1 and next(iter(s)) in allowed, f'unknown/malformed step {i}'
except Exception as e:
 print(f'FLOW FILE ERROR: {e}',file=sys.stderr); sys.exit(2)
PY
set +e
python3 - "$FLOW" "$DIR" "$ADB" "$ROOT/scripts/capture-screen.sh" <<'PY'
import json,sys,subprocess,time,os,re
flow_path,shotdir,adb,capture=sys.argv[1:]
d=json.load(open(flow_path,encoding='utf-8')); steps=d['steps']; total=len(steps); passed=0

def run(args, check=True):
 p=subprocess.run([adb,'shell']+args,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
 if check and p.returncode: raise RuntimeError(p.stdout.strip() or 'adb command failed')
 return p.stdout.strip()
def screenshot(i,name):
 safe=re.sub(r'[^A-Za-z0-9._-]+','-',name).strip('-') or 'capture'
 subprocess.run([capture,os.path.join(shotdir,f'{i:02d}-{safe}.png')],check=True,stdout=subprocess.PIPE,text=True)
def dump():
 run(['uiautomator','dump','/sdcard/window.xml'],check=False)
 return run(['cat','/sdcard/window.xml'],check=False)
def fail(i,msg,assertion=False):
 if assertion:
  try: screenshot(i,'failed-assert')
  except Exception: pass
 print(f'FLOW: FAIL at step {i} - {msg}'); sys.exit(1)
for i,step in enumerate(steps,1):
 kind,arg=next(iter(step.items()))
 try:
  if kind=='launch':
   pkg=arg['package']; run(['monkey','-p',pkg,'1'],check=False); time.sleep(1)
  elif kind=='wait': time.sleep(max(0,float(arg['seconds'])))
  elif kind=='tap':
   if 'xy' in arg:
    x,y=arg['xy']; run(['input','tap',str(int(x)),str(int(y))])
   elif 'text' in arg:
    xml=dump(); text=arg['text']; m=re.search(r'<node[^>]*text="'+re.escape(text)+r'"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"',xml)
    if not m: fail(i,f'text not found for tap: {text}',True)
    x1,y1,x2,y2=map(int,m.groups()); run(['input','tap',str((x1+x2)//2),str((y1+y2)//2)])
   else: raise ValueError('tap requires xy or text')
   time.sleep(1)
  elif kind=='swipe':
   coords={'left':(900,1200,200,1200),'right':(200,1200,900,1200),'up':(540,1700,540,600),'down':(540,600,540,1700)}
   x1,y1,x2,y2=coords[arg['direction']]; run(['input','swipe',str(x1),str(y1),str(x2),str(y2),'350']); time.sleep(1)
  elif kind=='key':
   keys={'BACK':'4','HOME':'3','ENTER':'66'}; run(['input','keyevent',keys[arg['name']]]); time.sleep(1)
  elif kind=='type': run(['input','text',arg['text'].replace(' ','%s')]); time.sleep(1)
  elif kind=='screenshot': screenshot(i,arg['name'])
  elif kind=='assert_foreground':
   focus=run(['dumpsys','window'],check=False)
   if arg['package'] not in focus: fail(i,f"foreground package does not contain {arg['package']}",True)
  elif kind=='assert_text':
   if arg['text'] not in dump(): fail(i,f"visible text not found: {arg['text']}",True)
  passed+=1
 except SystemExit: raise
 except Exception as e: fail(i,str(e),kind.startswith('assert'))
print(f'FLOW: PASS ({passed}/{total} steps)')
PY
RC=$?; set -e
exit "$RC"
