import UIKit
import SnapKit

final class PreviewAfterCompressView: UIView, CustomNavigationBarConfigurable {
    var onDeleteTap: VoidBlock?
    
    let keepOriginalButton = PrimaryButton(title: "Keep Original Video")
    let customNavigationBar = CustomNavigationBar(title: "Video Compressor")
    let sizeChangeView = SizeChangeView(nowText: "Old Size", willBeText: "Now")
    
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
        [deleteLabel, keepOriginalButton, sizeChangeView].forEach {
            addSubview($0)
        }
        sizeChangeView.updateSizes(now: "30.88 MB", willBe: "15.75 MB")
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
