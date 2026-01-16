import UIKit
import SnapKit

final class ScreenRecordingsViewController: UIViewController {
    
    private var screenRecordingsView: ScreenRecordingsView {
        return view as! ScreenRecordingsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        view = ScreenRecordingsView()
    }
}

private extension ScreenRecordingsViewController {
    
}
