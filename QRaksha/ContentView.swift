import SwiftUI
import UIKit

struct ContentView: View {
    @State private var showingScanner = false
    @State private var manualInput = ""
    @State private var currentAssessment: URLRiskAssessment?
    @State private var history: [ScanRecord] = []
    @State private var cameraMessage: String?
    @State private var selectedTab = 0

    private let analyzer = URLRiskAnalyzer()

    var body: some View {
        ZStack {
            Color(red: 0.035, green: 0.055, blue: 0.09).ignoresSafeArea()
            if selectedTab == 0 {
                dashboard
            } else {
                historyScreen
            }
        }
        .safeAreaInset(edge: .bottom) { bottomBar }
        .sheet(isPresented: $showingScanner) {
            scannerSheet
        }
        .preferredColorScheme(.dark)
    }

    private var dashboard: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                heroCard
                manualEntry
                if let cameraMessage {
                    Text(cameraMessage)
                        .font(.footnote)
                        .foregroundStyle(.orange)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
                }
                if let assessment = currentAssessment {
                    assessmentCard(assessment)
                }
                privacyNote
            }
            .padding(20)
            .padding(.bottom, 16)
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 15).fill(Color.cyan.opacity(0.15))
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 27, weight: .semibold))
                    .foregroundStyle(.cyan)
            }
            .frame(width: 54, height: 54)
            VStack(alignment: .leading, spacing: 3) {
                Text("QRaksha")
                    .font(.system(size: 27, weight: .bold, design: .rounded))
                Text("THE QR CODE FIREWALL")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(.cyan)
            }
            Spacer()
            Image(systemName: "shield.lefthalf.filled")
                .font(.title2)
                .foregroundStyle(.green)
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("ON-DEVICE ANALYSIS", systemImage: "iphone")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(.mint)
                Spacer()
                Circle().fill(.green).frame(width: 7, height: 7)
                Text("READY")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.green)
            }
            Text("Look before\nyou link.")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .fixedSize(horizontal: false, vertical: true)
            Text("Inspect QR destinations before opening them. Understand the warning signs, not just a score.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.68))
                .fixedSize(horizontal: false, vertical: true)
            Button {
                cameraMessage = nil
                showingScanner = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "viewfinder")
                    Text("Scan a QR code")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.black)
                .padding(17)
                .background(Color.cyan, in: RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
        }
        .padding(22)
        .background(
            LinearGradient(colors: [Color(red: 0.08, green: 0.18, blue: 0.25), Color(red: 0.07, green: 0.10, blue: 0.17)],
                           startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 26)
        )
        .overlay(RoundedRectangle(cornerRadius: 26).stroke(Color.cyan.opacity(0.22), lineWidth: 1))
    }

    private var manualEntry: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Inspect a link", subtitle: "No camera? Paste a destination.")
            HStack(spacing: 10) {
                Image(systemName: "link")
                    .foregroundStyle(.secondary)
                TextField("example.com/path", text: $manualInput)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .submitLabel(.go)
                    .onSubmit { analyzeManualInput() }
                Button {
                    analyzeManualInput()
                } label: {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(width: 36, height: 36)
                        .background(Color.cyan, in: RoundedRectangle(cornerRadius: 11))
                }
                .buttonStyle(.plain)
                .disabled(manualInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(12)
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.09), lineWidth: 1))
        }
    }

    private func assessmentCard(_ assessment: URLRiskAssessment) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Scan assessment", subtitle: "Evidence-based heuristics · not a guarantee")
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    Circle().stroke(Color.white.opacity(0.1), lineWidth: 7)
                    Circle()
                        .trim(from: 0, to: CGFloat(assessment.riskScore) / 100)
                        .stroke(riskColor(assessment.level), style: StrokeStyle(lineWidth: 7, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 0) {
                        Text("\(assessment.riskScore)")
                            .font(.system(size: 23, weight: .bold, design: .rounded))
                        Text("/100")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 76, height: 76)
                VStack(alignment: .leading, spacing: 5) {
                    Text(assessment.level.rawValue)
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(riskColor(assessment.level))
                    Text(assessment.host)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.75))
                        .textSelection(.enabled)
                    Text("Score is a heuristic, not a probability.")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("DESTINATION")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.4)
                    .foregroundStyle(.secondary)
                Text(assessment.normalizedURL?.absoluteString ?? assessment.originalInput)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.8))
                    .textSelection(.enabled)
                    .lineLimit(4)
                Button {
                    UIPasteboard.general.string = assessment.normalizedURL?.absoluteString ?? assessment.originalInput
                } label: {
                    Label("Copy destination", systemImage: "doc.on.doc")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.cyan)
                }
                .buttonStyle(.plain)
            }
            Divider().overlay(Color.white.opacity(0.08))
            Text("WHY IT WAS FLAGGED")
                .font(.system(size: 10, weight: .bold))
                .tracking(1.4)
                .foregroundStyle(.secondary)
            ForEach(assessment.findings) { finding in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: finding.points >= 20 ? "exclamationmark.triangle.fill" : "info.circle.fill")
                        .foregroundStyle(finding.points >= 20 ? .orange : .cyan)
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(finding.title)
                            .font(.system(size: 13, weight: .semibold))
                        Text(finding.detail)
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.62))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 6) {
                Label("RECOMMENDED NEXT STEP", systemImage: "hand.raised.fill")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(.mint)
                Text(assessment.recommendedAction)
                    .font(.system(size: 13, weight: .medium))
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.mint.opacity(0.08), in: RoundedRectangle(cornerRadius: 15))
            HStack {
                Button {
                    addHistory(assessment)
                } label: {
                    Label("Save to history", systemImage: "clock.arrow.circlepath")
                        .font(.footnote.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                Button {
                    currentAssessment = nil
                    manualInput = ""
                } label: {
                    Text("Clear")
                        .font(.footnote.weight(.semibold))
                        .padding(12)
                        .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }

    private var privacyNote: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "lock.shield")
                .foregroundStyle(.mint)
            VStack(alignment: .leading, spacing: 4) {
                Text("Private by design")
                    .font(.footnote.weight(.semibold))
                Text("This prototype analyzes URLs locally. It does not contact a reputation service, follow redirects, or open links automatically.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 16))
    }

    private var historyScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                sectionTitle("Scan history", subtitle: "Saved locally for this app session")
                if history.isEmpty {
                    ContentUnavailableView("No saved scans", systemImage: "clock", description: Text("Analyze a URL and tap Save to history."))
                        .padding(.top, 40)
                } else {
                    ForEach(history) { record in
                        Button {
                            currentAssessment = record.assessment
                            selectedTab = 0
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "qrcode")
                                    .foregroundStyle(riskColor(record.assessment.level))
                                    .frame(width: 42, height: 42)
                                    .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(record.displayHost)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.white)
                                    Text(record.scannedAt.formatted(date: .omitted, time: .shortened))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("\(record.assessment.riskScore)")
                                    .font(.headline.monospacedDigit())
                                    .foregroundStyle(riskColor(record.assessment.level))
                            }
                            .padding(14)
                            .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    }
                    Button("Clear history", role: .destructive) { history.removeAll() }
                        .font(.footnote.weight(.semibold))
                }
            }
            .padding(20)
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 0) {
            tabButton(title: "Protect", icon: "shield.lefthalf.filled", index: 0)
            tabButton(title: "History", icon: "clock.arrow.circlepath", index: 1)
        }
        .padding(.top, 10)
        .background(.ultraThinMaterial)
    }

    private func tabButton(title: String, icon: String, index: Int) -> some View {
        Button {
            selectedTab = index
        } label: {
            VStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 18, weight: .semibold))
                Text(title).font(.system(size: 10, weight: .semibold))
            }
            .foregroundStyle(selectedTab == index ? Color.cyan : Color.white.opacity(0.45))
            .frame(maxWidth: .infinity)
            .padding(.bottom, 6)
        }
        .buttonStyle(.plain)
    }

    private var scannerSheet: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScannerView(onCode: { value in
                    showingScanner = false
                    analyze(value)
                }, onError: { message in
                    cameraMessage = message
                })
                .ignoresSafeArea()
                VStack(spacing: 8) {
                    Image(systemName: "viewfinder")
                        .font(.system(size: 38, weight: .light))
                    Text("Align the QR code inside the camera view")
                        .font(.headline)
                    Text("QRaksha will inspect the destination without opening it.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                .padding(20)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { showingScanner = false }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private func sectionTitle(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.system(size: 19, weight: .bold, design: .rounded))
            Text(subtitle).font(.caption).foregroundStyle(.secondary)
        }
    }

    private func analyzeManualInput() {
        analyze(manualInput)
    }

    private func analyze(_ input: String) {
        let assessment = analyzer.analyze(input)
        currentAssessment = assessment
        manualInput = input
        selectedTab = 0
        if assessment.normalizedURL == nil {
            cameraMessage = assessment.findings.first?.detail
        } else {
            cameraMessage = nil
        }
    }

    private func addHistory(_ assessment: URLRiskAssessment) {
        guard !history.contains(where: { $0.rawValue == assessment.originalInput }) else { return }
        history.insert(ScanRecord(rawValue: assessment.originalInput, scannedAt: Date(), assessment: assessment), at: 0)
        if history.count > 30 { history = Array(history.prefix(30)) }
    }

    private func riskColor(_ level: RiskLevel) -> Color {
        switch level {
        case .low: return .green
        case .medium: return .orange
        case .high, .invalid: return .red
        }
    }
}

#Preview {
    ContentView()
}
