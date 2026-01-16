import UIKit
import SnapKit
import Combine

final class MainViewController: UIViewController {
    private let viewModel: MainViewModel
    private var cancellables = Set<AnyCancellable>()
    
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
        setupNotifications()
        viewModel.loadDiskInfo()
        viewModel.checkPhotoLibraryPermission()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.requestPermissionsAfterDelay()
    }
    
    override func loadView() {
        view = MainView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupMediaTableView () {
        mainView.mediaTableView.dataSource = self
        mainView.mediaTableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.medias.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: MediaGroupCell.reuseIdentifier,
            for: indexPath
        ) as! MediaGroupCell
        
        cell.configure(with: viewModel.medias[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.handleMediaCellTap()
    }
}

private extension MainViewController {
    func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc func handleAppWillEnterForeground() {
        viewModel.refreshData()
    }
    
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
        
        viewModel.$permissionGranted
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] granted in
                self?.handlePermissionResult(granted)
            }
            .store(in: &cancellables)
        
        viewModel.$medias
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.mainView.mediaTableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$alertModel
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] alertModel in
                self?.showAlert(alertModel)
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
    
    func handlePermissionResult(_ granted: Bool) {
        if granted {
            print("Photo library access granted")
            viewModel.unlockMedia()
        } else {
            print("Photo library access denied")
        }
    }
    
    func showAlert(_ model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        
        let primaryAction = UIAlertAction(
            title: model.primaryAction.title,
            style: .default
        ) { [weak self] _ in
            self?.handleAlertAction(model.primaryAction)
        }
        alert.addAction(primaryAction)
        
        if let secondaryAction = model.secondaryAction {
            let cancelAction = UIAlertAction(
                title: secondaryAction.title,
                style: .cancel
            ) { [weak self] _ in
                self?.handleAlertAction(secondaryAction)
            }
            alert.addAction(cancelAction)
        }
        
        present(alert, animated: true)
    }
    
    func handleAlertAction(_ action: AlertModel.AlertAction) {
        switch action.style {
        case .openSettings:
            openAppSettings()
        case .default, .cancel:
            action.handler?()
        }
    }
    
    func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }
}
