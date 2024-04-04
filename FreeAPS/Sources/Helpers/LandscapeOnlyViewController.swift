import SwiftUI
import UIKit

class LandscapeOnlyViewController: UIViewController {
    var hostingController: UIHostingController<AnyView>?

    init(hostingController: UIHostingController<AnyView>) {
        self.hostingController = hostingController
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let hostingController = self.hostingController {
            addChild(hostingController)
            view.addSubview(hostingController.view)
            hostingController.didMove(toParent: self)
            hostingController.view.frame = view.bounds
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .landscape
    }

    override var shouldAutorotate: Bool {
        true
    }
}
