# QRaksha — Pitch Deck Outline

Keep the deck to 6–7 slides. Use screenshots from the real app only after it has been built and tested.

## Slide 1 — QRaksha: Look before you link
**Subtitle:** A QR-code firewall for campus life  
One-liner: Inspect the destination and understand warning signs before opening a QR link.

Visual: QR code on a campus poster + a phone showing a destination warning.

## Slide 2 — The problem
- QR codes hide their destination in a small printed pattern.
- A malicious sticker can replace a legitimate campus QR code.
- Students may scan links for events, forms, payments, attendance, and Wi-Fi without inspecting the URL.
- Traditional scanning often moves the user straight toward the destination.

Speaker note: We are not claiming every QR code is dangerous; the problem is that the destination is hard to inspect before the scan.

## Slide 3 — Our solution
Show a simple 4-step flow:
Scan → Decode → Explain warning signs → User decides

Key points:
- Destination visible before opening
- Explainable, on-device heuristics
- No automatic opening
- No API key or cloud lookup required for the MVP

## Slide 4 — Product demo
Use actual app screenshots after Xcode verification:
1. Home screen / scan button
2. Decoded URL and hostname
3. Findings and recommended next action
4. Manual URL entry fallback

Do not present mockups as screenshots of a working build.

## Slide 5 — How it works
- AVFoundation reads QR payloads.
- Foundation parses and normalizes HTTP/HTTPS URLs.
- Local rules inspect URL structure and selected warning patterns.
- A transparent heuristic score groups the result into caution levels.
- The app explains the evidence and does not open the link.

Add a small note: No live reputation database in the current prototype.

## Slide 6 — Differentiation, safety, and limits
Differentiators:
- Inspect before opening
- Evidence, not just a red/green verdict
- Privacy-first local analysis
- Campus-focused use cases

Limits:
- Heuristics can miss threats and create false positives.
- HTTPS is not proof of legitimacy.
- The score is not a probability.
- No live reputation or redirect-chain analysis yet.

## Slide 7 — Roadmap and ask
Near-term:
- Verify and polish iOS build
- Add safer domain/IDN display
- Improve test coverage and accessibility
- Add optional, consent-based reputation checks in a later version

Ask:
- Feedback from campus users and event organizers
- Help testing edge cases
- Mentorship on safe URL reputation integration

## 30-second pitch
“QRaksha is a QR-code safety checkpoint for campus life. When a student scans an event, payment, or notice QR code, QRaksha shows the actual destination and explains warning signs before the link is opened. The current prototype works on-device, never opens links automatically, and uses explainable heuristics rather than pretending to guarantee safety. Our goal is to give users a clear decision point at the moment they need it.”
