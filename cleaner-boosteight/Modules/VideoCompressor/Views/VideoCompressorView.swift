import UIKit
import SnapKit

final class VideoCompressorView: MainCommonView, CustomNavigationBarConfigurable {
    let customNavigationBar = CustomNavigationBar(title: "Video Compressor")
    
    private let videoInfoBadge = InfoBadgeView(title: "1746 Videos", icon: .videoBadge)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCustomNavigationBar()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension VideoCompressorView {
    func setupConstraints() {
        [videoInfoBadge].forEach {
            addSubview($0)
        }
        
        videoInfoBadge.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(8)
            $0.top.equalTo(customNavigationBar.snp.bottom).offset(8)
        }
    }
}
