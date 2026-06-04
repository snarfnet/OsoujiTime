import SwiftUI

// MARK: - Dustpan background shape
struct DustpanShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // Dustpan body - rounded trapezoid
        let topInset: CGFloat = w * 0.15
        let bottomRadius: CGFloat = w * 0.08
        let topY: CGFloat = h * 0.12
        let bottomY: CGFloat = h * 0.78

        path.move(to: CGPoint(x: topInset, y: topY))
        path.addLine(to: CGPoint(x: w - topInset, y: topY))
        path.addLine(to: CGPoint(x: w * 0.92, y: bottomY - bottomRadius))
        path.addQuadCurve(
            to: CGPoint(x: w * 0.92 - bottomRadius, y: bottomY),
            control: CGPoint(x: w * 0.92, y: bottomY)
        )
        path.addLine(to: CGPoint(x: w * 0.08 + bottomRadius, y: bottomY))
        path.addQuadCurve(
            to: CGPoint(x: w * 0.08, y: bottomY - bottomRadius),
            control: CGPoint(x: w * 0.08, y: bottomY)
        )
        path.closeSubpath()

        // Handle
        let handleW: CGFloat = w * 0.12
        let handleH: CGFloat = h * 0.18
        let handleX: CGFloat = (w - handleW) / 2
        let handleY: CGFloat = bottomY
        path.addRoundedRect(
            in: CGRect(x: handleX, y: handleY, width: handleW, height: handleH),
            cornerSize: CGSize(width: handleW / 2, height: handleW / 2)
        )

        return path
    }
}

// MARK: - Broom shape (clock hand style)
struct BroomView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Handle (stick)
            RoundedRectangle(cornerRadius: 3)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.72, green: 0.53, blue: 0.3), Color(red: 0.6, green: 0.42, blue: 0.22)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: 8, height: 90)

            // Bristles
            ZStack {
                // Bristle bundle
                ForEach(-3..<4, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(red: 0.85, green: 0.72, blue: 0.4))
                        .frame(width: 5, height: 40)
                        .offset(x: CGFloat(i) * 6)
                }
                // Band
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(red: 0.5, green: 0.35, blue: 0.18))
                    .frame(width: 46, height: 8)
                    .offset(y: -14)
            }
            .frame(height: 40)
        }
    }
}
