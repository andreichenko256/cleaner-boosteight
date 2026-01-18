import UIKit
import SnapKit

final class CompressingView: UIView {
    var onBackTap: VoidBlock?
    
    lazy var backWhiteArrow = {
        $0.contentMode = .scaleAspectFit
        $0.snp.makeConstraints { make in
            make.size.equalTo(32)
        }
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBackTap)))
        return $0
    }(UIImageView(image: .lightArrow))
    
    let cancelButton = PrimaryButton(title: "Cancel")
    
    let progressLabel = {
        $0.text = "44%"
        $0.numberOfLines = 0
        $0.textColor = Colors.primaryWhite
        $0.font = .systemFont(ofSize: 24, weight: .semibold)
        return $0
    }(UILabel())
    
    private let loadingIndicator = {
        $0.style = .large
        $0.hidesWhenStopped = true
        $0.color = .black
        return $0
    }(UIActivityIndicatorView())
    
    private let compressingLabel = {
        $0.text = "Compessing Video ..."
        $0.numberOfLines = 0
        $0.textColor = Colors.primaryWhite
        $0.font = .systemFont(ofSize: 24, weight: .semibold)
        return $0
    }(UILabel())
    
    private let dontCloseLabel = {
        $0.text = "Please don’t close the app in order\nnot to lose all progress"
        $0.textAlignment = .center
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    private let containerView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension CompressingView {
    func setupUI() {
        backgroundColor = Colors.secondaryBlue
    }
    
    func setupConstraints() {
        [backWhiteArrow,
         containerView,
         cancelButton,
         dontCloseLabel].forEach {
            addSubview($0)
        }
        
        backWhiteArrow.snp.makeConstraints {
            $0.top.equalTo(safeTop).inset(8)
            $0.leading.equalToSuperview().inset(16)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(backWhiteArrow.snp.bottom).offset(238)
            $0.centerX.equalToSuperview()
        }
        
        dontCloseLabel.snp.makeConstraints {
            $0.centerX.equalTo(cancelButton)
            $0.bottom.equalTo(cancelButton.snp.top).offset(-24)
        }
        
        cancelButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(13)
            $0.trailing.equalToSuperview().inset(19)
            $0.bottom.equalTo(safeBottom).inset(18)
        }
        
        setupContainerView()
    }
    
    func setupContainerView() {
        [loadingIndicator, progressLabel, compressingLabel ].forEach {
            containerView.addSubview($0)
        }
        
        loadingIndicator.snp.makeConstraints {
            $0.centerX.top.equalToSuperview()
        }
        
        progressLabel.snp.makeConstraints {
            $0.top.equalTo(loadingIndicator.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
        }
        loadingIndicator.startAnimating()
        compressingLabel.snp.makeConstraints {
            $0.top.equalTo(progressLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    @objc func handleBackTap() {
        onBackTap?()
    }
}
