import Foundation

struct ScanRecord: Identifiable {
    let id = UUID()
    let rawValue: String
    let scannedAt: Date
    let assessment: URLRiskAssessment

    var displayHost: String {
        guard let url = URL(string: rawValue) else { return rawValue }
        return url.host ?? rawValue
    }
}
