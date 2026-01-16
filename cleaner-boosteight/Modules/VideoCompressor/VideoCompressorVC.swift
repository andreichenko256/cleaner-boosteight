import UIKit
import SnapKit

final class VideoCompressorViewController: UIViewController {
    
    private var videoCompressorView: VideoCompressorView {
        return view as! VideoCompressorView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        view = VideoCompressorView()
    }
}

private extension VideoCompressorViewController {
    
}
