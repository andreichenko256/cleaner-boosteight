import UIKit
import SnapKit

class MainCommonView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MainCommonView {
    func setupUI() {
        backgroundColor = .white
    }
}
