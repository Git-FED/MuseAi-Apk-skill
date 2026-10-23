# New flow checklist

> **Never put real credentials in a flow file. Test accounts only. Never include steps that buy, send, post, or delete.**

## App
- [ ] Package: `________________`
- [ ] Launcher activity (if known): `________________`
- [ ] Version/build under test: `________________`

## Entry
- [ ] First screen: `________________`
- [ ] Exact visible text that recognizes it (`assert_text`): `________________`

## Main screens
| Screen name | How to reach it (safe action) | Exact `assert_text` |
|---|---|---|
| | | |
| | | |
| | | |

## Critical actions
| Action | Expected visible result |
|---|---|
| | |
| | |

## Switching and navigation
- [ ] Back behavior: `________________`
- [ ] Tab/switch gestures: `________________`
- [ ] No destructive or sensitive action included.

## Sign-off
- [ ] Flow file name: `________________`
- [ ] Author: `________________`
- [ ] Date: `________________`
- [ ] Tested against configured AVD: `________________`
