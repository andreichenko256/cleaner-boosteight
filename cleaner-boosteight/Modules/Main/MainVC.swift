import UIKit
import SnapKit

final class MainViewController: UIViewController {
    
    private var mainView: MainView {
        return view as! MainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.circularProgressView.setProgress(0.1, animated: true, duration: 3)
    }
    
    override func loadView() {
        view = MainView()
    }
}

private extension MainViewController {
    
}
