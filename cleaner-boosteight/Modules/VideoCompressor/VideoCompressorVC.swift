import UIKit
import SnapKit

final class VideoCompressorViewController: UIViewController {
    var onBack: VoidBlock?
    var onVideoSelected: ((VideoModel) -> Void)?
    
    private var videoCompressorView: VideoCompressorView {
        return view as! VideoCompressorView
    }
    
    private let viewModel: VideoCompressorVMProtocol
    
    init(viewModel: VideoCompressorVMProtocol = VideoCompressorVM()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupBackButton()
        bindViewModel()
        viewModel.loadVideos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadVideos()
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
        return viewModel.videosCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: VideoCompressorCell.reuseIdentifier,
            for: indexPath
        ) as? VideoCompressorCell else {
            return UICollectionViewCell()
        }
        
        let video = viewModel.videos[indexPath.item]
        cell.configure(with: video)
        
        let thumbnailSize = CGSize(width: 352, height: 352)
        viewModel.getThumbnail(for: indexPath.item, targetSize: thumbnailSize) { [weak cell, weak collectionView] thumbnail in
            guard let cell = cell,
                  let collectionView = collectionView,
                  let currentIndexPath = collectionView.indexPath(for: cell),
                  currentIndexPath == indexPath else {
                return
            }
            cell.updateThumbnail(thumbnail)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let video = viewModel.videos[indexPath.item]
        onVideoSelected?(video)
    }
}

private extension VideoCompressorViewController {
    func setupBackButton() {
        videoCompressorView.customNavigationBar.onBackTap = { [weak self] in
            self?.onBack?()
        }
    }
    
    func bindViewModel() {
        viewModel.onVideosUpdated = { [weak self] in
            guard let self = self else { return }
            self.videoCompressorView.videosCollectionView.reloadData()
            self.videoCompressorView.updateVideoInfo(
                count: self.viewModel.videosCount,
                size: self.viewModel.formattedTotalSize
            )
        }
        
        viewModel.onError = { [weak self] errorMessage in
            self?.showError(errorMessage)
        }
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension VideoCompressorViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize(width: 0, height: 0)
        }
        
        let interItemSpacing: CGFloat = 8
        let numberOfItemsPerRow: CGFloat = 2
        
        let sectionInsets = flowLayout.sectionInset
        let availableWidth = collectionView.bounds.width -
            sectionInsets.left -
            sectionInsets.right -
            (interItemSpacing * (numberOfItemsPerRow - 1))
        let itemWidth = availableWidth / numberOfItemsPerRow
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
}
