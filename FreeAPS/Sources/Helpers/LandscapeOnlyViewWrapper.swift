import SwiftUI
import UIKit

struct LandscapeOnlyViewWrapper<Content: View>: UIViewControllerRepresentable {
    var content: Content

    func makeUIViewController(context _: Context) -> UIViewController {
        let hostingController = UIHostingController(rootView: AnyView(content))
        let landscapeViewController = LandscapeOnlyViewController(hostingController: hostingController)
        return landscapeViewController
    }

    func updateUIViewController(_: UIViewController, context _: Context) {
        // Here, you can update the view controller if needed when your SwiftUI state changes.
    }
}
