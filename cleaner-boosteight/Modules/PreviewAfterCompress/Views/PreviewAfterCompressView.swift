import UIKit
import SnapKit

final class PreviewAfterCompressView: UIView, CustomNavigationBarConfigurable {
    var onDeleteTap: VoidBlock?
    
    let keepOriginalButton = PrimaryButton(title: "Keep Original Video")
    let customNavigationBar = CustomNavigationBar(title: "Video Compressor")
    let sizeChangeView = SizeChangeView(nowText: "Old Size", willBeText: "Now")
    
    let videoContainerView = {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
        return $0
    }(UIView())
    
    private lazy var deleteLabel = {
        $0.text = "Delete Original Video"
        $0.textColor = Colors.primaryBlue
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.numberOfLines = 0
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDeleteTap)))
        return $0
    }(UILabel())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCustomNavigationBar()
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension PreviewAfterCompressView {
    func setupUI() {
        backgroundColor = .white
    }
    
    func setupConstraints() {
        [deleteLabel, keepOriginalButton, sizeChangeView, videoContainerView].forEach {
            addSubview($0)
        }
        
        videoContainerView.snp.makeConstraints {
            $0.top.equalTo(customNavigationBar.snp.bottom).offset(25)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(sizeChangeView.snp.top).offset(-26)
        }
        
        keepOriginalButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(safeBottom).inset(16)
        }
        
        deleteLabel.snp.makeConstraints {
            $0.bottom.equalTo(keepOriginalButton.snp.top).offset(-16)
            $0.horizontalEdges.equalTo(keepOriginalButton)
        }
        
        sizeChangeView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(deleteLabel.snp.top).offset(-28)
        }
    }
}

private extension PreviewAfterCompressView {
    @objc func handleDeleteTap() {
        onDeleteTap?()
    }
}
