import SwiftUI

// MARK: - Realistic dustpan background
struct DustpanView: View {
    var size: CGFloat = 280

    var body: some View {
        ZStack {
            // Shadow
            DustpanBodyShape()
                .fill(Color.black.opacity(0.08))
                .frame(width: size, height: size * 1.25)
                .offset(x: 3, y: 4)

            // Main body
            DustpanBodyShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.55, green: 0.72, blue: 0.6),
                            Color(red: 0.45, green: 0.62, blue: 0.5),
                            Color(red: 0.4, green: 0.55, blue: 0.45)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: size, height: size * 1.25)

            // Inner floor (darker)
            DustpanInnerShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.38, green: 0.52, blue: 0.42),
                            Color(red: 0.32, green: 0.45, blue: 0.36)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: size * 0.82, height: size * 0.85)
                .offset(y: -size * 0.05)

            // Front lip highlight
            DustpanLipShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.62, green: 0.78, blue: 0.66),
                            Color(red: 0.5, green: 0.68, blue: 0.55)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: size * 0.92, height: size * 0.1)
                .offset(y: -size * 0.52)

            // Metal rim
            DustpanLipShape()
                .stroke(
                    Color(red: 0.6, green: 0.6, blue: 0.58),
                    lineWidth: 2.5
                )
                .frame(width: size * 0.93, height: size * 0.1)
                .offset(y: -size * 0.52)

            // Handle
            ZStack {
                // Handle shaft
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.48, green: 0.48, blue: 0.46),
                                Color(red: 0.55, green: 0.55, blue: 0.52),
                                Color(red: 0.48, green: 0.48, blue: 0.46)
                            ],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .frame(width: size * 0.05, height: size * 0.28)

                // Handle grip
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.3, green: 0.3, blue: 0.28),
                                Color(red: 0.4, green: 0.4, blue: 0.38)
                            ],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .frame(width: size * 0.07, height: size * 0.12)
                    .offset(y: size * 0.09)
            }
            .offset(y: size * 0.52)

            // Rivets
            ForEach([-1, 1], id: \.self) { side in
                Circle()
                    .fill(Color(red: 0.5, green: 0.5, blue: 0.48))
                    .frame(width: size * 0.025, height: size * 0.025)
                    .offset(x: CGFloat(side) * size * 0.35, y: -size * 0.42)
            }
        }
    }
}

// MARK: - Dustpan body path
struct DustpanBodyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        let topY = h * 0.08
        let bottomY = h * 0.75
        let lipCurve = h * 0.04

        // Front lip (slightly curved)
        path.move(to: CGPoint(x: w * 0.06, y: topY + lipCurve))
        path.addQuadCurve(
            to: CGPoint(x: w * 0.94, y: topY + lipCurve),
            control: CGPoint(x: w * 0.5, y: topY - lipCurve)
        )
        // Right side (tapers out slightly)
        path.addLine(to: CGPoint(x: w * 0.9, y: bottomY))
        // Bottom (rounded)
        path.addQuadCurve(
            to: CGPoint(x: w * 0.1, y: bottomY),
            control: CGPoint(x: w * 0.5, y: bottomY + h * 0.06)
        )
        path.closeSubpath()

        return path
    }
}

// MARK: - Inner floor shape
struct DustpanInnerShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: w * 0.05, y: h * 0.08))
        path.addLine(to: CGPoint(x: w * 0.95, y: h * 0.08))
        path.addLine(to: CGPoint(x: w * 0.9, y: h * 0.88))
        path.addQuadCurve(
            to: CGPoint(x: w * 0.1, y: h * 0.88),
            control: CGPoint(x: w * 0.5, y: h * 0.95)
        )
        path.closeSubpath()

        return path
    }
}

// MARK: - Front lip shape
struct DustpanLipShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: 0, y: h))
        path.addQuadCurve(
            to: CGPoint(x: w, y: h),
            control: CGPoint(x: w * 0.5, y: 0)
        )

        return path
    }
}

// MARK: - Broom shape (clock hand style)
struct BroomView: View {
    var scale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 0) {
            // Handle (wooden stick)
            ZStack {
                RoundedRectangle(cornerRadius: 3 * scale)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.75, green: 0.58, blue: 0.35),
                                Color(red: 0.65, green: 0.48, blue: 0.28),
                                Color(red: 0.72, green: 0.55, blue: 0.32)
                            ],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .frame(width: 8 * scale, height: 90 * scale)

                // Wood grain lines
                ForEach(0..<3, id: \.self) { i in
                    Rectangle()
                        .fill(Color(red: 0.6, green: 0.42, blue: 0.22).opacity(0.3))
                        .frame(width: 0.5 * scale, height: 80 * scale)
                        .offset(x: CGFloat(i - 1) * 2.5 * scale)
                }
            }

            // Bristles
            ZStack {
                // Bristle bundle
                ForEach(-4..<5, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 1.5 * scale)
                        .fill(
                            Color(
                                red: 0.82 + Double.random(in: -0.05...0.05),
                                green: 0.68 + Double.random(in: -0.05...0.05),
                                blue: 0.35 + Double.random(in: -0.05...0.05)
                            )
                        )
                        .frame(width: 4.5 * scale, height: (38 + CGFloat.random(in: -4...0)) * scale)
                        .offset(x: CGFloat(i) * 5.5 * scale)
                }

                // Metal band
                RoundedRectangle(cornerRadius: 2 * scale)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.55, green: 0.55, blue: 0.52),
                                Color(red: 0.65, green: 0.65, blue: 0.6),
                                Color(red: 0.55, green: 0.55, blue: 0.52)
                            ],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .frame(width: 52 * scale, height: 8 * scale)
                    .offset(y: -15 * scale)
            }
            .frame(height: 40 * scale)
        }
    }
}
