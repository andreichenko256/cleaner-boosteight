import UIKit
import SnapKit
import Combine

final class MediaViewController: UIViewController {
    private let viewModel: MediaViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private var mediaView: MediaView {
        return view as! MediaView
    }
    
    init(viewModel: MediaViewModel = MediaViewModel()) {
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
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        return viewModel.mediaItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MediaCell.reuseIdentifier,
            for: indexPath
        ) as! MediaCell
        
        let mediaItem = viewModel.mediaItems[indexPath.item]
        cell.configure(with: mediaItem)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.handleMediaItemTap(at: indexPath.item)
    }
}

private extension MediaViewController {
    func setupBackButton() {
        mediaView.customNavigationBar.onBackTap = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    func setupBindings() {
        viewModel.$mediaItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.mediaView.mediaCollectionView.reloadData()
            }
            .store(in: &cancellables)
    }
}
