import Foundation

enum RiskLevel: String {
    case low = "Lower risk"
    case medium = "Caution"
    case high = "High risk signals"
    case invalid = "Invalid or unsupported"
}

struct RiskFinding: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let detail: String
    let points: Int
}

struct URLRiskAssessment {
    let originalInput: String
    let normalizedURL: URL?
    let riskScore: Int
    let level: RiskLevel
    let findings: [RiskFinding]
    let recommendedAction: String

    var host: String {
        normalizedURL?.host ?? "No valid host"
    }
}

struct URLRiskAnalyzer {
    // Small demo list only; this is not a comprehensive brand database.
    private let lookalikeBrandTokens = [
        "paypal", "apple", "google", "microsoft", "amazon", "instagram"
    ]

    private let knownShorteners: Set<String> = [
        "bit.ly", "tinyurl.com", "t.co", "is.gd", "cutt.ly", "rb.gy", "shorturl.at"
    ]

    func analyze(_ input: String) -> URLRiskAssessment {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return invalid(input, reason: "No URL was provided.")
        }

        let hasExplicitScheme = trimmed.range(
            of: #"^[A-Za-z][A-Za-z0-9+.-]*:"#,
            options: .regularExpression
        ) != nil
        let hasHTTPURLPrefix = trimmed.range(
            of: #"(?i)^https?://"#,
            options: .regularExpression
        ) != nil

        // Do not turn unsupported schemes (such as javascript:) into HTTPS URLs.
        if hasExplicitScheme && !hasHTTPURLPrefix {
            return invalid(input, reason: "Only HTTP and HTTPS URLs are supported.")
        }

        let candidate = hasHTTPURLPrefix ? trimmed : "https://" + trimmed

        guard let components = URLComponents(string: candidate),
              let scheme = components.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              let host = components.host,
              !host.isEmpty,
              let url = components.url else {
            return invalid(input, reason: "Enter a complete HTTP or HTTPS URL, or scan a QR code containing one.")
        }

        var findings: [RiskFinding] = []
        let normalizedHost = host.lowercased()
        var score = 0

        func add(_ title: String, _ detail: String, _ points: Int) {
            findings.append(RiskFinding(title: title, detail: detail, points: points))
            score += points
        }

        if scheme != "https" {
            add("Connection is not HTTPS",
                "The URL uses HTTP. Traffic may not be encrypted in transit. This alone does not prove the site is malicious.",
                20)
        }

        if components.user != nil || components.password != nil {
            add("Embedded credentials or user-info",
                "The URL contains text before the @ separator. This can make the real destination harder to notice.",
                30)
        }

        if isIPAddress(normalizedHost) {
            add("IP address used as host",
                "The destination uses a raw IP address instead of a conventional domain. Some legitimate services do this, but it deserves scrutiny.",
                20)
        }

        if normalizedHost.hasPrefix("xn--") || normalizedHost.contains(".xn--") ||
            normalizedHost.unicodeScalars.contains(where: { $0.value > 127 }) {
            add("Internationalized or Unicode hostname",
                "Unicode and punycode domains can be legitimate, but visually similar characters may be used to imitate another domain.",
                20)
        }

        let labels = normalizedHost.split(separator: ".")
        if normalizedHost.count > 55 {
            add("Unusually long hostname",
                "Long hostnames can obscure the meaningful part of a destination.",
                10)
        }
        if labels.count >= 5 {
            add("Many subdomains",
                "This hostname has several labels. Read the domain from right to left and identify the registrable domain carefully.",
                10)
        }

        if knownShorteners.contains(normalizedHost) {
            add("Shortened URL",
                "The final destination is hidden behind a URL shortener. QRaksha does not expand or follow it automatically.",
                20)
        }

        if hasBrandLookalikeSignal(host: normalizedHost) {
            add("Possible brand impersonation pattern",
                "The hostname contains a familiar brand token in an unexpected domain structure. Verify the exact registered domain independently.",
                25)
        }

        let suspiciousPatterns: [(String, String, Int)] = [
            (#"%[0-9A-Fa-f]{2}.*%[0-9A-Fa-f]{2}"#, "Repeated percent-encoding", 8),
            (#"(?i)(login|verify|account|secure|password|wallet|claim|gift)"#, "Sensitive-action wording in URL", 8),
            (#"(?i)(free[-_]?gift|urgent[-_]?verify|password[-_]?reset)"#, "Common lure-like URL wording", 12)
        ]
        for (pattern, title, points) in suspiciousPatterns {
            if candidate.range(of: pattern, options: .regularExpression) != nil {
                add(title, "This pattern can appear on legitimate pages too. Treat it as a clue, not a verdict.", points)
            }
        }

        score = min(score, 100)
        let level: RiskLevel
        if score >= 50 { level = .high }
        else if score >= 20 { level = .medium }
        else { level = .low }

        let action: String
        switch level {
        case .high:
            action = "Do not proceed unless you can independently verify the destination."
        case .medium:
            action = "Pause and verify the exact domain with the organization that shared the QR code."
        case .low:
            action = "No configured warning rules triggered. This does not guarantee the site is safe."
        case .invalid:
            action = "Do not open this input. Check that it is a valid HTTP or HTTPS URL."
        }

        if findings.isEmpty {
            findings.append(RiskFinding(
                title: "No configured warning rules triggered",
                detail: "This on-device prototype has no live reputation database. A clean result is not a safety guarantee.",
                points: 0
            ))
        }

        return URLRiskAssessment(
            originalInput: input,
            normalizedURL: url,
            riskScore: score,
            level: level,
            findings: findings,
            recommendedAction: action
        )
    }

    private func invalid(_ input: String, reason: String) -> URLRiskAssessment {
        URLRiskAssessment(
            originalInput: input,
            normalizedURL: nil,
            riskScore: 100,
            level: .invalid,
            findings: [RiskFinding(title: "Cannot analyze this URL", detail: reason, points: 100)],
            recommendedAction: "Do not open this input. Check that it is a valid HTTP or HTTPS URL."
        )
    }

    private func isIPAddress(_ host: String) -> Bool {
        let parts = host.split(separator: ".", omittingEmptySubsequences: false)
        if parts.count == 4 && parts.allSatisfy({ part in
            guard let value = Int(part) else { return false }
            return (0...255).contains(value) && !part.isEmpty
        }) {
            return true
        }
        // Basic IPv6 literal detection.
        return host.contains(":") && !host.contains("[") && !host.contains("]")
    }

    private func hasBrandLookalikeSignal(host: String) -> Bool {
        let labels = host.split(separator: ".").map(String.init)
        guard labels.count >= 2 else { return false }
        let labelsBeforeTLD = labels.dropLast().joined(separator: ".")
        for brand in lookalikeBrandTokens {
            if labelsBeforeTLD.contains(brand) && !isLikelyFirstParty(labels: labels, brand: brand) {
                return true
            }
        }
        return false
    }

    private func isLikelyFirstParty(labels: [String], brand: String) -> Bool {
        guard labels.count == 2 else { return false }
        return labels[0] == brand
    }
}
