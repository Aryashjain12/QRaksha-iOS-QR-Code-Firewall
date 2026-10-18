# QRaksha — Project Plan

## One-line pitch
QRaksha is an iOS QR-code safety checkpoint that shows the decoded destination and explains suspicious URL signals before a student decides whether to open it.

## Problem
QR codes are convenient, but the destination is hidden in the printed code. A sticker placed over a legitimate campus QR code can redirect students to a fake login page, payment page, survey, or event form. Many users scan first and inspect later.

## Target users
- Students scanning event registrations, campus notices, attendance forms, Wi-Fi setup pages, or payment posters
- Campus clubs and event organizers who want a safer QR-scanning experience
- Any user who wants to inspect a QR destination before opening it

## Proposed solution
1. Scan a QR code or paste a URL.
2. Decode and display the exact destination host.
3. Run transparent, on-device URL heuristics.
4. Show a risk-indicator score, evidence, and a practical next step.
5. Let the user decide. Never open a link automatically.

## What the current prototype includes
- Native SwiftUI iOS interface
- Camera QR scanning using AVFoundation
- Manual URL entry
- Local, deterministic checks for HTTP, embedded user-info, IP hosts, Unicode/punycode, long hostnames, many subdomains, known URL shorteners, brand-token lookalikes, and lure-like URL wording
- Explainable findings and recommended actions
- Session-only scan history
- Unit-test starter cases
- No external API key or network dependency

## What the score means
The score is a heuristic priority indicator from 0–100. It is not a probability, a reputation verdict, or a guarantee. A low score does not mean a URL is safe. A high score means the prototype found signals worth checking.

## MVP boundaries
Not included in this prototype:
- Live domain reputation or threat-intelligence lookups
- Redirect-chain expansion
- Website content inspection
- Malware scanning
- Automatic link opening
- Cloud sync or persistent history

These are deliberate boundaries for a privacy-first demo. Future network features should use explicit consent, strict timeouts, redirect limits, and safe isolation.

## Success criteria for the hackathon demo
- Scan a QR code on a physical iPhone and show its decoded destination
- Demonstrate manual URL analysis when camera access is unavailable
- Explain at least two findings for a suspicious test URL
- Show a benign example and clearly explain why a clean result is not a guarantee
- Complete the demo without opening a suspicious link or requiring internet access

## Suggested team split
- iOS/UI: SwiftUI screens, camera scanner, state handling
- Security/logic: URL parsing, scoring rules, tests, edge cases
- Product/demo: user research, pitch, safe demo QR codes, README, slides

For a team of 3, combine product/demo with testing. Everyone should be able to explain the limitations and the demo flow.

## Immediate checklist
- [ ] Publish the repository and README
- [ ] Open the project in Xcode on a Mac
- [ ] Build and run on a simulator
- [ ] Test camera permission and scan on a physical iPhone
- [ ] Run unit tests and fix compiler/test issues
- [ ] Review each risk rule for false positives
- [ ] Prepare three controlled QR codes for the demo
- [ ] Capture real app screenshots after a successful build
- [ ] Prepare the 90-second demo and 3-minute pitch

## Honest status
This repository is a starter prototype generated for hackathon development. It has not yet been compiled or run in Xcode in this environment. Treat the first Mac/Xcode session as a verification and debugging step, not as a guaranteed build.
