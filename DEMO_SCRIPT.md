# QRaksha demo script (90 seconds)

## Opening (10 sec)
"QR codes hide the destination until after you scan them. QRaksha lets students inspect that destination first."

## Demo 1: Normal URL (20 sec)
Paste `https://example.com`. Point out that no warning rules triggered. Explain that the result is not a safety guarantee.

## Demo 2: Suspicious signals (25 sec)
Paste `http://192.0.2.10/login`. Show the HTTP and raw-IP findings. This uses a documentation-only IP range and is not intended to host a real service.

## Demo 3: Lookalike hostname (20 sec)
Paste `https://paypal.com.example.org/login`. Explain that the actual hostname is `paypal.com.example.org`, not `paypal.com`.

## Close (15 sec)
"QRaksha doesn't claim every suspicious URL is malicious. It explains what it can observe, avoids opening links automatically, and gives students a safer decision point."
