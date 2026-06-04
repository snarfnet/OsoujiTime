import SwiftUI
import AVFoundation
import UserNotifications

struct TimerView: View {
    @State private var selectedMinutes: Int = 10
    @State private var remainingSeconds: Int = 0
    @State private var totalSeconds: Int = 0
    @State private var isRunning = false
    @State private var isPaused = false
    @State private var timer: Timer?
    @State private var broomAngle: Double = 0
    @State private var showComplete = false
    @State private var audioPlayer: AVAudioPlayer?

    private let presets = [5, 10, 15, 30, 45, 60, 90, 120]

    private let bgTop = Color(red: 0.93, green: 0.96, blue: 1.0)
    private let bgBottom = Color(red: 0.98, green: 0.94, blue: 0.96)
    private let accentGreen = Color(red: 0.4, green: 0.75, blue: 0.55)
    private let brownText = Color(red: 0.35, green: 0.25, blue: 0.15)

    var body: some View {
        ZStack {
            LinearGradient(colors: [bgTop, bgBottom], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Text("お掃除タイム")
                    .onAppear { requestNotificationPermission() }
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(red: 0.35, green: 0.55, blue: 0.4))
                    .padding(.top, 20)

                Spacer()

                // Clock face with broom hand
                ZStack {
                    Image("clockface")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)

                    // Broom as clock hand - knob at clock center, bristles sweep outward
                    if isRunning || isPaused {
                        Image("broomhand")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 165, height: 165)
                            .blendMode(.multiply)
                            .rotationEffect(.degrees(broomAngle - 45), anchor: UnitPoint(x: 0.22, y: 0.78))
                            .offset(x: 46, y: -46)
                            .animation(.linear(duration: 0.5), value: broomAngle)
                    } else {
                        Image("broomhand")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .blendMode(.multiply)
                            .rotationEffect(.degrees(-45), anchor: UnitPoint(x: 0.22, y: 0.78))
                            .offset(x: 46, y: -46)
                    }

                    // Sparkles when running
                    if isRunning {
                        ForEach(0..<6, id: \.self) { i in
                            SparkleView()
                                .offset(
                                    x: CGFloat.random(in: -120...120),
                                    y: CGFloat.random(in: -120...120)
                                )
                        }
                    }
                }
                .frame(width: 300, height: 300)
                .clipped()
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.15), radius: 10, y: 4)

                // Remaining time below the clock
                if isRunning || isPaused {
                    VStack(spacing: 4) {
                        Text(timeString(remainingSeconds))
                            .font(.system(size: 52, weight: .bold, design: .monospaced))
                            .foregroundColor(brownText)

                        Text(isPaused ? "一時停止中" : "おそうじ中...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 16)
                }

                Spacer()

                if !isRunning && !isPaused {
                    timeSelector
                } else {
                    timerControls
                }

                Spacer().frame(height: 40)
            }

            if showComplete {
                completeOverlay
            }
        }
    }

    // MARK: - Time selector
    private var timeSelector: some View {
        VStack(spacing: 16) {
            Text("おそうじ時間を選んでね")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)

            LazyVGrid(columns: [
                GridItem(.flexible()), GridItem(.flexible()),
                GridItem(.flexible()), GridItem(.flexible())
            ], spacing: 12) {
                ForEach(presets, id: \.self) { minutes in
                    Button {
                        selectedMinutes = minutes
                    } label: {
                        Text("\(minutes)分")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(selectedMinutes == minutes ? .white : accentGreen)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedMinutes == minutes ? accentGreen : accentGreen.opacity(0.1))
                            )
                    }
                }
            }
            .padding(.horizontal, 24)

            Button {
                startTimer()
            } label: {
                HStack(spacing: 8) {
                    Text("🧹")
                    Text("おそうじスタート！")
                        .fontWeight(.bold)
                }
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(accentGreen)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: accentGreen.opacity(0.4), radius: 8, y: 4)
            }
            .padding(.horizontal, 32)
            .padding(.top, 8)
        }
    }

    // MARK: - Timer controls
    private var timerControls: some View {
        HStack(spacing: 20) {
            Button {
                isPaused ? resumeTimer() : pauseTimer()
            } label: {
                Image(systemName: isPaused ? "play.fill" : "pause.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.orange)
                    .clipShape(Circle())
            }

            Button {
                stopTimer()
            } label: {
                Image(systemName: "stop.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.red.opacity(0.8))
                    .clipShape(Circle())
            }
        }
    }

    // MARK: - Completion overlay
    private var completeOverlay: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()

            VStack(spacing: 20) {
                Text("✨🧹✨")
                    .font(.system(size: 60))

                Text("おそうじ完了！")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(accentGreen)

                Text("おつかれさまでした！")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.9))

                Button {
                    showComplete = false
                } label: {
                    Text("もどる")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(accentGreen)
                        .clipShape(Capsule())
                }
                .padding(.top, 8)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
            )
            .padding(.horizontal, 32)
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
        remainingSeconds = 0
        broomAngle = 0
    }

    private func completeTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
        showComplete = true

        // Strong haptic vibration pattern
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            generator.notificationOccurred(.warning)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            generator.notificationOccurred(.success)
        }

        // System sound
        AudioServicesPlaySystemSound(1005)

        // Local notification (for background)
        let content = UNMutableNotificationContent()
        content.title = "お掃除完了！"
        content.body = "おつかれさまでした！✨🧹✨"
        content.sound = .default
        let request = UNNotificationRequest(identifier: "osouji_done", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    private func timeString(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

struct SparkleView: View {
    @State private var opacity: Double = 0
    @State private var yOffset: CGFloat = 0

    var body: some View {
        Text("✨")
            .font(.system(size: CGFloat.random(in: 12...20)))
            .opacity(opacity)
            .offset(y: yOffset)
            .onAppear {
                withAnimation(.easeInOut(duration: Double.random(in: 1.5...3.0)).repeatForever(autoreverses: true)) {
                    opacity = Double.random(in: 0.4...1.0)
                    yOffset = CGFloat.random(in: -20...20)
                }
            }
    }
}
