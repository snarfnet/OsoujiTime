import SwiftUI
import WatchKit

struct WatchTimerView: View {
    @State private var selectedMinutes: Int = 10
    @State private var remainingSeconds: Int = 0
    @State private var totalSeconds: Int = 0
    @State private var isRunning = false
    @State private var isPaused = false
    @State private var timer: Timer?
    @State private var broomAngle: Double = 0
    @State private var showComplete = false

    private let presets = [5, 10, 15, 30, 45, 60, 90, 120]
    private let accentGreen = Color(red: 0.4, green: 0.75, blue: 0.55)

    var body: some View {
        if showComplete {
            completeView
        } else if isRunning || isPaused {
            timerRunningView
        } else {
            presetView
        }
    }

    // MARK: - Preset selection
    private var presetView: some View {
        ScrollView {
            VStack(spacing: 6) {
                Text("🧹 お掃除タイム")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(accentGreen)

                ForEach(presets, id: \.self) { minutes in
                    Button {
                        selectedMinutes = minutes
                        startTimer()
                    } label: {
                        Text("\(minutes)分")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(accentGreen.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 4)
        }
    }

    // MARK: - Timer running
    private var timerRunningView: some View {
        VStack(spacing: 4) {
            // Dustpan + broom
            ZStack {
                // Mini dustpan
                WatchDustpanShape()
                    .fill(accentGreen.opacity(0.25))
                    .overlay(
                        WatchDustpanShape()
                            .stroke(accentGreen.opacity(0.5), lineWidth: 1.5)
                    )
                    .frame(width: 100, height: 90)

                // Broom hand
                WatchBroomView()
                    .rotationEffect(.degrees(broomAngle), anchor: .bottom)
                    .offset(y: -18)
                    .animation(.linear(duration: 0.5), value: broomAngle)
            }
            .frame(height: 95)

            // Time
            Text(timeString(remainingSeconds))
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(accentGreen)

            Text(isPaused ? "⏸ 一時停止" : "おそうじ中...")
                .font(.system(size: 11))
                .foregroundColor(.secondary)

            // Controls
            HStack(spacing: 12) {
                Button {
                    isPaused ? resumeTimer() : pauseTimer()
                } label: {
                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                        .font(.system(size: 16))
                }
                .foregroundColor(.orange)

                Button {
                    stopTimer()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 16))
                }
                .foregroundColor(.red)
            }
        }
    }

    // MARK: - Complete
    private var completeView: some View {
        VStack(spacing: 8) {
            Text("✨🧹✨")
                .font(.system(size: 30))
            Text("おそうじ完了！")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(accentGreen)
            Text("おつかれさま！")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            Button("もどる") {
                showComplete = false
            }
            .foregroundColor(accentGreen)
        }
    }

    // MARK: - Timer logic
    private func startTimer() {
        totalSeconds = selectedMinutes * 60
        remainingSeconds = totalSeconds
        broomAngle = 0
        isRunning = true
        isPaused = false
        startTicking()
    }

    private func startTicking() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard isRunning, !isPaused else { return }
            remainingSeconds -= 1
            let elapsed = totalSeconds - remainingSeconds
            broomAngle = Double(elapsed) / Double(totalSeconds) * 360.0
            if remainingSeconds <= 0 { completeTimer() }
        }
    }

    private func pauseTimer() { isPaused = true }
    private func resumeTimer() { isPaused = false }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
    }

    private func completeTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        showComplete = true
        WKInterfaceDevice.current().play(.success)
    }

    private func timeString(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

// MARK: - Watch-sized dustpan
struct WatchDustpanShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: w * 0.08, y: h * 0.12))
        path.addQuadCurve(
            to: CGPoint(x: w * 0.92, y: h * 0.12),
            control: CGPoint(x: w * 0.5, y: h * 0.02)
        )
        path.addLine(to: CGPoint(x: w * 0.88, y: h * 0.78))
        path.addQuadCurve(
            to: CGPoint(x: w * 0.12, y: h * 0.78),
            control: CGPoint(x: w * 0.5, y: h * 0.88)
        )
        path.closeSubpath()
        // Handle
        path.addRoundedRect(
            in: CGRect(x: w * 0.44, y: h * 0.78, width: w * 0.12, height: h * 0.2),
            cornerSize: CGSize(width: w * 0.06, height: w * 0.06)
        )
        return path
    }
}

// MARK: - Watch-sized broom
struct WatchBroomView: View {
    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(red: 0.72, green: 0.55, blue: 0.32))
                .frame(width: 4, height: 32)
            ZStack {
                ForEach(-2..<3, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color(red: 0.82, green: 0.68, blue: 0.38))
                        .frame(width: 3, height: 16)
                        .offset(x: CGFloat(i) * 4)
                }
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color(red: 0.5, green: 0.5, blue: 0.48))
                    .frame(width: 24, height: 4)
                    .offset(y: -5)
            }
            .frame(height: 16)
        }
    }
}
