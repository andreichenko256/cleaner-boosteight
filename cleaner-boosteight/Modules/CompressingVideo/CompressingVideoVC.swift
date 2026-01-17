import UIKit
import SnapKit

final class CompressingVideoViewController: UIViewController {
    
    private var compressingView: CompressingView {
        return view as! CompressingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        view = CompressingView()
    }
}

private extension CompressingVideoViewController {
    
}
