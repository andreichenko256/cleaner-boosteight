import UIKit
import SnapKit

final class LivePhotosViewController: UIViewController {
    
    private var livePhotosView: LivePhotosView {
        return view as! LivePhotosView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        view = LivePhotosView()
    }
}

private extension LivePhotosViewController {
    
}
