# Standalone index.html generation prompt

Write `index.html` — a single, self-contained, eye-catching landing page for “APK Tester Skill” (Git-FED's Muse skill: Muse run-tests any Android APK on a virtual phone and returns a PASS/FAIL report with screenshots as proof). Inline CSS + JS only, no build step, no external framework, dark theme with one loud accent color, big type, mobile-first.

## Sections, in order
0. HEADER: a continuously looping ticker with short APK-testing phrases; keep it decorative and readable, and disable/reduce movement for `prefers-reduced-motion`.
1. HERO: headline “Your AI tests the APK. Screenshots prove it.” + routine summary, CSS phone mockup showing a clearly illustrative test run ending in a green PASS badge, and “See how it works”.
2. THE ROUTINE: six cards — Install, Launch, Screenshot, Logcat, Walk flows, Report.
3. SAMPLE REPORT: styled card matching `templates/test-report.md`, explicitly illustrative/not a real test; package `com.fedos.musenumberthree`.
4. FIRST JOB: the intended Muse Number 3 check: all 3 slots open, swipe switching works, 3 logins stay separate (login separation needs actual human-reviewed evidence; do not claim automation).
5. JOIN EMAIL LIST: center the Discord-style FedPromptly widget horizontally on the page; scoped widget/modal per `prompts/EMAIL-LIST-PROMPT.md`; use Supabase public values supplied in that file; no nested HTML document, IDs once.
6. AGE-GATED SUPPORT: whole payment block is overlaid until explicit age confirmation; payment embed markup must not be present in the DOM or loaded before confirmation. Store confirmation in sessionStorage. After confirmation, inject options in exact order: PayPal, GitHub Sponsors, Buy Me a Coffee, NOWPayments, Stripe. Do not include Ko-fi or its floating widget. Payment snippets below must be preserved verbatim.
7. PROMO CODES: render exactly the offers from `prompts/PROMO-CODES-PROMPT.md`.
8. FOOTER: exact public FED-OS footer in `docs/ultimate-file-tree.md` under “FOOTER PROMPT”; four columns, no Matrix, personal Substack, or Facebook.

## Motion and layout
Use polished, eye-catching but restrained CSS motion (looping ticker, gentle hero motion, hover feedback). Respect `prefers-reduced-motion`. Keep the email-list widget centered.

## Head and constraints
Title: “APK Tester Skill — Muse tests your APK, screenshots prove it”; meta description; OG image `assets/og-image.png`; favicon set under `assets/favicon/`; theme-color `#25d982`. No links to other HTML pages. Page must still be readable with JavaScript disabled except the gated support area, which says to enable JS and confirm age. Do not claim setup has run. Don't use fake screenshots or represent a mockup as a real app capture.

### Verbatim payment embed snippets

Preserve and inject the following five payment options only after age confirmation, in exactly this order. Ko-fi and its floating widget are intentionally removed.

```html
   <div id="paypal-button-container-P-4FD24238VX4902214NK2XP2Y"></div>
   <script src="https://www.paypal.com/sdk/js?client-id=BAA_ndqaWMyQwTnDZ0LXwLQ22jdJo9uxkeXYqmBbF-hD41HMiZ83mvOcx1Kti0b6ZfXfje7Q1ievNaS8Ok&vault=true&intent=subscription" data-sdk-integration-source="button-factory"></script>
   <script>
     paypal.Buttons({
         style: { shape: 'rect', color: 'gold', layout: 'vertical', label: 'subscribe' },
         createSubscription: function(data, actions) {
           return actions.subscription.create({ plan_id: 'P-4FD24238VX4902214NK2XP2Y', quantity: 1 });
         },
         onApprove: function(data, actions) { alert(data.subscriptionID); }
     }).render('#paypal-button-container-P-4FD24238VX4902214NK2XP2Y');
   </script>
   <iframe src="https://github.com/sponsors/Git-FED/button" title="Sponsor Git-FED" height="32" width="114" style="border: 0; border-radius: 6px;"></iframe>
   <a href="https://www.buymeacoffee.com/fedpromptly"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a book&emoji=📖&slug=fedpromptly&button_colour=FFDD00&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=ffffff" /></a>
   <a href="https://nowpayments.io/payment/?iid=5997958570&source=button" target="_blank" rel="noreferrer noopener"><img src="https://nowpayments.io/images/embeds/payments-button-white.svg" alt="Cryptocurrency & Bitcoin payment button by NOWPayments" /></a>
   <script async src="https://js.stripe.com/v3/buy-button.js"></script>
   <stripe-buy-button buy-button-id="buy_btn_1UJKaaJaRf233kfWKZ81fcIe" publishable-key="pk_live_51UIdAGJaRf233kfWlFacR31IYVGdjCVAttNFzIgQGXQzrUdc894iJcBqamRZNwF11z2AN5kvjyzitor462f2egVI00UmKj0sd8"></stripe-buy-button>
```

DONE = eye-catching single-page site; no payment embeds in initial DOM/network; after age confirmation, the five remaining options load in the given order, and no Ko-fi script or widget is present.
