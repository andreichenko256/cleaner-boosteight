import UIKit
import SnapKit

final class VideoCompressorView: MainCommonView, CustomNavigationBarConfigurable {
    let customNavigationBar = CustomNavigationBar(title: "Video Compressor")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
        setupCustomNavigationBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension VideoCompressorView {
    func setupConstraints() {
        [].forEach {
            addSubview($0)
        }
        
    }
}
