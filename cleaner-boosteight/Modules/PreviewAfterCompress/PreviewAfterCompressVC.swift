import UIKit
import SnapKit

final class PreviewAfterCompressViewController: UIViewController {
    
    private var previewAfterCompressView: PreviewAfterCompressView {
        return view as! PreviewAfterCompressView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        view = PreviewAfterCompressView()
    }
}

private extension PreviewAfterCompressViewController {
    
}
