import UIKit
import SnapKit

final class ScreenPhotosViewController: UIViewController {
    
    private var screenPhotosView: ScreenPhotosView {
        return view as! ScreenPhotosView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        view = ScreenPhotosView()
    }
}

private extension ScreenPhotosViewController {
    
}
