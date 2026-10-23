# FedPromptly “Join Email List” component prompt

Implement only the widget, modal, scoped styles, and script inside the target page; never nest a second `<html>` document. Scope all CSS under a wrapper (for example `.fed-auth`) and ensure each element ID appears exactly once. This prompt reproduces the supplied functional specification; the separate original standalone HTML source was not present in the repository input, so do not claim byte-for-byte source equivalence.

Use Supabase JS v2 from `https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2`, project URL `https://qyuczfpgydgqywgthgrz.supabase.co`, and the supplied public publishable key `sb_publishable_2NLEuDREplLS9DgUXeA8Tw_f8MJOhCq`. These are browser-side public project settings, not a service-role secret.

Widget: Discord-style invite card (`#2b2d31`), green glowing status dot (`statusDot`, #23a55a), `statusText` (“Join now” / “Signed in”), readonly fake email input `emailInput`, keyboard-accessible `openSignupBtn` role=button (Enter/Space opens), hint “Click to join our email list”. Typewriter phrases exactly “Type your email here…”, “Join our newsletter…”, “Get early access…”, “Stay in the loop…”; 65ms/character, 30ms delete, 1600ms hold, 350ms between phrases, `|` cursor.

Modal `authModal`: close ×, click-outside and Escape close; title “Join Email List”, sub “Stay updated with FEDPromptly”; email `loginEmail`, password `loginPassword` (minlength 6), “Forgot password?”; `authSubmitBtn` switches “Join Email List”/“Sign In”; message area `authMessage` with error/success/info states; divider “or”; toggle `toggleAuthMode`/`toggleText` (“Already joined? Sign In” / “New here? Join Email List”). Support signup, sign-in, reset password, sign-out, initial session lookup, and auth-state synchronization. Handle already registered (including identities length 0 / “User already registered”), unconfirmed email, and invalid credentials with friendly clear messages. Redirect auth emails to the current page.

Logged-in view `loggedInView`: gradient initial avatar `loggedInAvatar`, prefix `loggedInName`, email `loggedInEmail`, thank-you copy “Thank you for joining our email list!” and “We will be reaching out soon… email me anytime: contact@fedpromptly.com” linked via mailto, plus `logoutBtn`.

Visuals: Inter, dark variables `--bg-body #0b0b10`, `--bg-card #14141e`, `--bg-input #1e1e2f`, purple gradient #7c5cfc→#a78bfa, pill primary button, 1.5rem modal radius, blurred backdrop. Match behavior and values exactly; do not put secrets in the client.
