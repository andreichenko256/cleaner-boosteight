import UIKit

final class PrimaryButton: UIButton {
    var onTap: VoidBlock?
    
    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setupUI()
        setupTargetActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 60)
    }
}

private extension PrimaryButton {
    func setupUI() {
        backgroundColor = Colors.primaryBlue
        setTitleColor(Colors.primaryWhite, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        layer.cornerRadius = 16
    }
}

private extension PrimaryButton {
    func setupTargetActions() {
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }
    
    @objc func handleTap() {
        onTap?()
    }
}
