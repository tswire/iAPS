import SwiftDate
import SwiftUI
import UIKit

private var backgroundGradient: RadialGradient {
    RadialGradient(
        gradient: Gradient(colors: [
            Color(red: 0.262745098, green: 0.7333333333, blue: 0.9137254902),
            Color(red: 0.3411764706, green: 0.6666666667, blue: 0.9254901961),
            Color(red: 0.4862745098, green: 0.5450980392, blue: 0.9529411765),
            Color(red: 0.6235294118, green: 0.4235294118, blue: 0.9803921569),
            Color(red: 0.7215686275, green: 0.3411764706, blue: 1)
        ]),
        center: .center,
        startRadius: 27.0,
        endRadius: 0.0
    )
}

struct LoopView: View {
    private enum Config {
        static let lag: TimeInterval = 30
    }

    @Binding var suggestion: Suggestion?
    @Binding var enactedSuggestion: Suggestion?
    @Binding var closedLoop: Bool
    @Binding var timerDate: Date
    @Binding var isLooping: Bool
    @Binding var lastLoopDate: Date
    @Binding var manualTempBasal: Bool
    @State private var scale: CGFloat = 1.0

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        VStack(alignment: .center) {
            ZStack {
                if isLooping {
                    PulsatingCircleView(color: color)
                    /* ProgressView() */
                } else {
                    Circle()
                        .strokeBorder(color, lineWidth: 4.5)
                        .frame(width: 27, height: 27)
                        .scaleEffect(1)
                }
            }
            if isLooping {
                /* Text("looping").font(.caption2) */
                Text(timeString).font(.caption2)
                    .foregroundColor(.secondary)
            } else if manualTempBasal {
                Text("Manual").font(.caption2)
            } else if actualSuggestion?.timestamp != nil {
                Text(timeString).font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                Text("--").font(.caption2).foregroundColor(.secondary)
            }
        }
    }

    private var timeString: String {
        let minAgo = Int((timerDate.timeIntervalSince(lastLoopDate) - Config.lag) / 60) + 1
        if minAgo > 1440 {
            return "--"
        }
        return "\(minAgo) " + NSLocalizedString("min", comment: "Minutes ago since last loop")
    }

    private var color: Color {
        guard actualSuggestion?.timestamp != nil else {
            return .loopGray
        }
        guard manualTempBasal == false else {
            return .loopManualTemp
        }
        let delta = timerDate.timeIntervalSince(lastLoopDate) - Config.lag

        if delta <= 5.minutes.timeInterval {
            guard actualSuggestion?.deliverAt != nil else {
                return .loopYellow
            }
            return .loopGreen
        } else if delta <= 10.minutes.timeInterval {
            return .loopYellow
        } else {
            return .loopRed
        }
    }

    func mask(in rect: CGRect) -> Path {
        var path = Rectangle().path(in: rect)
        if !closedLoop || manualTempBasal {
            path.addPath(Rectangle().path(in: CGRect(x: rect.minX, y: rect.midY - 5, width: rect.width, height: 10)))
        }
        return path
    }

    private var actualSuggestion: Suggestion? {
        if closedLoop, enactedSuggestion?.recieved == true {
            return enactedSuggestion ?? suggestion
        } else {
            return suggestion
        }
    }
}

/* extension View {
     func animateForever(
         using animation: Animation = Animation.easeInOut(duration: 1),
         autoreverses: Bool = false,
         _ action: @escaping () -> Void
     ) -> some View {
         let repeated = animation.repeatForever(autoreverses: autoreverses)

         return onAppear {
             withAnimation(repeated) {
                 action()
             }
         }
     }
 } */

struct PulsatingCircleView: View {
    var color: Color
    var size: CGFloat = 20.0
    @State private var animate = false

    var body: some View {
        ZStack {
//            Circle()
//                .fill(color)
//                .frame(width: 27, height: 27)
//                .scaleEffect(animate ? 0.6 : 1.2)
//                .animation(
//                    Animation.easeInOut(duration: 1).repeatForever(autoreverses: true),
//                    value: animate
//                )
            Circle()
                .fill(backgroundGradient)
                .frame(width: 27, height: 27)
                .scaleEffect(animate ? 0.0 : 1.2)
                .animation(
                    Animation.easeInOut(duration: 2).repeatForever(autoreverses: true),
                    value: animate
                )
        }
        .onAppear {
            self.animate = true
        }
    }
}
