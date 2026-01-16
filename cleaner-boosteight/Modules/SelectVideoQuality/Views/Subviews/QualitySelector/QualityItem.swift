import UIKit
import SnapKit

final class QualityItem: UIView {
    var isSelected: Bool = false {
        didSet {
            updateSelectionState()
        }
    }
    
    var onTap: VoidBlock?
    
    private let titleLabel = {
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = Colors.primaryBlue
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    private let checkIcon = {
        $0.contentMode = .scaleAspectFit
        $0.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        return $0
    }(UIImageView(image: .uncheckMark))
    
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupUI()
        setupConstraints()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension QualityItem {
    func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 10
        
        setupShadow()
    }
    
    func setupConstraints() {
        [titleLabel, checkIcon].forEach {
            addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.verticalEdges.equalToSuperview().inset(20.5)
        }
        
        checkIcon.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(16)
        }
    }
    
    func setupShadow() {
        layer.shadowColor = Colors.primaryBlack.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 3.8 / 2
        layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }
    
    @objc func handleTap() {
        onTap?()
    }
    
    func updateSelectionState() {
        let image: UIImage? = isSelected ? .blueCheckmark : .uncheckMark
        checkIcon.image = image
    }
}
