import UIKit
import SnapKit
import Combine

final class MainViewController: UIViewController {
    private let viewModel: MainViewModel
    private var cancellables = Set<AnyCancellable>()
    
    let medias: [MediaGroupModel] = [
        .init(type: .videoCompressor, mediaCount: 33, mediaSize: 33),
        .init(type: .media, mediaCount: 33, mediaSize: 33)
    ]
    
    private var mainView: MainView {
        return view as! MainView
    }
    
    init(viewModel: MainViewModel = MainViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        setupMediaTableView()
        viewModel.loadDiskInfo()
    }
    
    override func loadView() {
        view = MainView()
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupMediaTableView () {
        mainView.mediaTableView.dataSource = self
        mainView.mediaTableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medias.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: MediaGroupCell.reuseIdentifier,
            for: indexPath
        ) as! MediaGroupCell
        
        cell.configure(with: medias[indexPath.row])
        
        return cell
    }
}

private extension MainViewController {
    func setupBindings() {
        viewModel.$diskInfoDisplayModel
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayModel in
                self?.updateUI(with: displayModel)
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.handleError(error)
            }
            .store(in: &cancellables)
    }
    
    func updateUI(with displayModel: MainViewModel.DiskInfoDisplayModel) {
        mainView.valueStorageLabel.setTexts(
            semibold: displayModel.usedSpaceText,
            regular: displayModel.totalSpaceText,
            fontSize: 16,
            color: Colors.primaryWhite
        )
        
        mainView.circularProgressView.setProgress(
            displayModel.usagePercentage,
            animated: true,
            duration: 1.5
        )
    }
    
    func handleError(_ error: Error) {
        print("Failed to load disk info: \(error)")
        mainView.circularProgressView.setProgress(0, animated: false)
    }
}
