import UIKit
import SnapKit

final class DuplicatePhotosViewController: UIViewController {
    
    private var duplicateSimilarView: DuplicateSimilarView {
        return view as! DuplicateSimilarView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        view = DuplicateSimilarView(title: "Duplicate Photos", type: .duplicate)
    }
}

private extension DuplicatePhotosViewController {
    
}
