import UIKit
import SnapKit
import Combine

final class CompressingVideoViewController: UIViewController {
    var onCancel: VoidBlock?
    var onCompletion: ((URL) -> Void)?

    private let viewModel: CompressingVideoViewModelProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    private var compressingView: CompressingView {
        return view as! CompressingView
    }
    
    init(viewModel: CompressingVideoViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCancelButton()
        setupBackButton()
        bindViewModel()
        viewModel.startCompression()
    }
    
    override func loadView() {
        view = CompressingView()
    }
    
    deinit {
        viewModel.cancelCompression()
    }
}

private extension CompressingVideoViewController {
    func setupCancelButton() {
        compressingView.cancelButton.addTarget(
            self,
            action: #selector(cancelButtonTapped),
            for: .touchUpInside
        )
    }
    
    func setupBackButton() {
        compressingView.onBackTap = { [weak self] in
            self?.handleCancel()
        }
    }
    
    func bindViewModel() {
        viewModel.progressPercentagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] percentage in
                self?.compressingView.progressLabel.text = percentage
            }
            .store(in: &cancellables)
        
        viewModel.completionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] url in
                self?.onCompletion?(url)
            }
            .store(in: &cancellables)
        
        viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] errorMessage in
                self?.showError(errorMessage)
            }
            .store(in: &cancellables)
    }
    
    @objc func cancelButtonTapped() {
        handleCancel()
    }
    
    func handleCancel() {
        viewModel.cancelCompression()
        onCancel?()
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.onCancel?()
        })
        present(alert, animated: true)
    }
}
