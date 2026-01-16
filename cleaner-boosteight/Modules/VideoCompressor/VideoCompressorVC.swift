import UIKit
import SnapKit

final class VideoCompressorViewController: UIViewController {
    
    var onBack: VoidBlock?
    
    private var videoCompressorView: VideoCompressorView {
        return view as! VideoCompressorView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupBackButton()
    }
    
    override func loadView() {
        view = VideoCompressorView()
    }
}

extension VideoCompressorViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    private func setupCollectionView() {
        videoCompressorView.videosCollectionView.delegate = self
        videoCompressorView.videosCollectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        100
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCompressorCell.reuseIdentifier, for: indexPath)
        
        return cell
    }
    
}

private extension VideoCompressorViewController {
    func setupBackButton() {
        videoCompressorView.customNavigationBar.onBackTap = { [weak self] in
            self?.onBack?()
        }
    }
}
