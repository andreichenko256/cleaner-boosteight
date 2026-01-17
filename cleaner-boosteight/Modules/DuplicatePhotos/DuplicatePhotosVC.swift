import UIKit
import SnapKit

final class DuplicatePhotosViewController: UIViewController {
    
    private var duplicateSimilarView: DuplicateSimilarView {
        return view as! DuplicateSimilarView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
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
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DuplicateSimilarCell.reuseIdentifier, for: indexPath) as! DuplicateSimilarCell
        
        return cell
    }
}
