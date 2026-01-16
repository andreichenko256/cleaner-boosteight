import UIKit
import SnapKit

final class SelectVideoQualityView: MainCommonView, CustomNavigationBarConfigurable {
    let customNavigationBar = CustomNavigationBar(title: "Video Compressor")
    let compressButton = PrimaryButton(title: "")
    let qualitySelector = QualitySelector()
    let sizeChangeView = SizeChangeView()
    
    let videoContainerView = {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
        return $0
    }(UIView())
    
    private let compressContainerView: UIView = {
        let container = UIView()
        container.isUserInteractionEnabled = false
        
        let label = UILabel()
        label.text = "Compress"
        label.textColor = Colors.primaryWhite
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 1

        let imageView = UIImageView(image: .compressIcon)
        imageView.contentMode = .scaleAspectFit

        container.addSubview(imageView)
        container.addSubview(label)

        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalTo(label)
        }

        label.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(11.67)
            make.trailing.equalToSuperview()
            make.verticalEdges.equalToSuperview()
        }
        
        return container
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
        setupCustomNavigationBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SelectVideoQualityView {
    func setupConstraints() {
        [customNavigationBar, videoContainerView,
         compressButton, qualitySelector, sizeChangeView].forEach {
            addSubview($0)
        }
        
        videoContainerView.snp.makeConstraints {
            $0.top.equalTo(customNavigationBar.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(sizeChangeView.snp.top).offset(-18)
        }
        
        compressButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(safeBottom).inset(16)
        }
        
        compressButton.addSubview(compressContainerView)
        compressContainerView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        qualitySelector.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12.83)
            $0.trailing.equalToSuperview().inset(19.17)
            $0.bottom.equalTo(compressButton.snp.top).offset(-18)
        }
        
        sizeChangeView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(qualitySelector.snp.top).offset(-19)
        }
    }
}
