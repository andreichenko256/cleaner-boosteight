import UIKit
import SnapKit
import Combine

final class DuplicatePhotosViewController: UIViewController {
    private let viewModel: DuplicatePhotosViewModel
    private var cancellables = Set<AnyCancellable>()
    private let photoFetchService = PhotoFetchService()
    
    private var duplicateSimilarView: DuplicateSimilarView {
        return view as! DuplicateSimilarView
    }
    
    init(viewModel: DuplicatePhotosViewModel = DuplicatePhotosViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupBindings()
        setupActions()
        viewModel.loadData()
    }
    
    override func loadView() {
        view = DuplicateSimilarView(title: "Duplicate Photos")
    }
}

extension DuplicatePhotosViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        duplicateSimilarView.tableView.dataSource = self
        duplicateSimilarView.tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.duplicateGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DuplicateSimilarCell.reuseIdentifier, for: indexPath) as! DuplicateSimilarCell
        
        guard indexPath.row < viewModel.duplicateGroups.count else {
            return cell
        }
        
        let group = viewModel.duplicateGroups[indexPath.row]
        let duplicateCount = group.count - 1
        cell.configure(with: group, count: duplicateCount, photoFetchService: photoFetchService)
        
        return cell
    }
}

private extension DuplicatePhotosViewController {
    func setupBindings() {
        viewModel.$duplicateGroups
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.duplicateSimilarView.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$count
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.duplicateSimilarView.countInfoBadge.updateTitle("\(count)")
            }
            .store(in: &cancellables)
        
        viewModel.$totalSize
            .receive(on: DispatchQueue.main)
            .sink { [weak self] size in
                self?.duplicateSimilarView.sizeInfoBadge.updateTitle(size)
            }
            .store(in: &cancellables)
    }
    
    func setupActions() {
        duplicateSimilarView.customNavigationBar.onBackTap = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
}
