import UIKit
import SnapKit

protocol CustomNavigationBarConfigurable {
    var customNavigationBar: CustomNavigationBar { get }
    func setupCustomNavigationBar()
}

extension CustomNavigationBarConfigurable where Self: UIView {
    func setupCustomNavigationBar() {
        addSubview(customNavigationBar)
        customNavigationBar.snp.makeConstraints {
            $0.top.equalTo(safeTop).inset(17.33)
            $0.horizontalEdges.equalToSuperview()
        }
    }
}

final class CustomNavigationBar: UIView {
    var onBackTap: VoidBlock?
    
    lazy var arrowLeftImageView = {
        $0.contentMode = .scaleAspectFit
        $0.tintColor = Colors.primaryBlack
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBackTap)))
        return $0
    }(UIImageView(image: .arrowLeft))
    
    private let titleLabel = {
        $0.textColor = Colors.primaryBlack
        $0.font = .systemFont(ofSize: 24, weight: .semibold)
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    init(title: String = "") {
        super.init(frame: .zero)
        titleLabel.text = title
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension CustomNavigationBar {
    func setupConstraints() {
        [arrowLeftImageView,
         titleLabel].forEach {
            addSubview($0)
        }
        
        arrowLeftImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(28)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(arrowLeftImageView.snp.bottom).offset(25.33)
            $0.leading.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview()
        }
    }
    
    @objc func handleBackTap() {
        onBackTap?()
    }
}
