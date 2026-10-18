# QRaksha Test Plan

Run these checks on a Mac after opening the project in Xcode. Camera tests require a physical device; manual URL tests can be run in the simulator.

## URL analyzer cases

| Input | Expected observation |
|---|---|
| `https://example.com` | Valid URL; no configured warning rules expected |
| `example.com` | Normalized to HTTPS |
| `http://example.com` | HTTP warning |
| `http://192.0.2.10/login` | HTTP and IP-host findings |
| `https://paypal.com.example.org/login` | Actual host shown as `paypal.com.example.org`; brand-token warning |
| `https://bit.ly/abc123` | Shortener warning |
| `javascript:alert(1)` | Invalid/unsupported |
| Empty input | Invalid/unsupported |
| `https://user:pass@example.com` | Embedded user-info warning |
| A Unicode/punycode test domain | Internationalized-hostname warning when Foundation exposes the Unicode/punycode form |
| Very long host / many subdomains | Relevant structural warning when thresholds are met |

## UI and device checks
- [ ] App opens without crashing
- [ ] Manual entry accepts a bare domain and a full URL
- [ ] Invalid inputs show an understandable error state
- [ ] Camera permission prompt appears on first scan
- [ ] Denied camera permission shows a useful fallback message
- [ ] Valid QR payload is displayed for analysis
- [ ] Scanner does not open the destination automatically
- [ ] Reopening the scanner after a scan works correctly
- [ ] Long URLs remain selectable/copyable and do not break layout
- [ ] VoiceOver labels and contrast are usable
- [ ] App works without internet for the local checks

## Demo safety
Only use controlled, non-malicious test payloads. Do not use a real phishing page, collect credentials, or open a suspicious link during the presentation.
