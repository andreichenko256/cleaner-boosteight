import UIKit
import SnapKit

final class SelectVideoQualityViewController: UIViewController {
    
    private var electVideoQualityView: SelectVideoQualityView {
        return view as! SelectVideoQualityView
    }
    
    private var selectedQuality: VideoQuality = .medium
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupQualitySelector()
        setupCompressButton()
    }
    
    override func loadView() {
        view = SelectVideoQualityView()
    }
}

private extension SelectVideoQualityViewController {
    func setupQualitySelector() {
        electVideoQualityView.qualitySelector.onQualitySelected = { [weak self] quality in
            self?.handleQualitySelection(quality)
        }
    }
    
    func setupCompressButton() {
        electVideoQualityView.compressButton.addTarget(
            self,
            action: #selector(compressButtonTapped),
            for: .touchUpInside
        )
    }
    
    func handleQualitySelection(_ quality: VideoQuality) {
        selectedQuality = quality
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    @objc func compressButtonTapped() {
        
    }
}
