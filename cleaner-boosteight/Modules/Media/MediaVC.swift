import UIKit
import SnapKit

final class MediaViewController: UIViewController {
    
    private var mediaView: MediaView {
        return view as! MediaView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    override func loadView() {
        view = MediaView()
    }
}

extension MediaViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    private func setupCollectionView() {
        mediaView.mediaCollectionView.delegate = self
        mediaView.mediaCollectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaCell.reuseIdentifier, for: indexPath)
        
        return cell
    }
}

private extension MediaViewController {
    
}
