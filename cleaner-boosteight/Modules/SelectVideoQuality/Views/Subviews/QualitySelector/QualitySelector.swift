import UIKit

enum VideoQuality {
    case low
    case medium
    case high
}

final class QualitySelector: UIStackView {
    var onQualitySelected: ((VideoQuality) -> Void)?
    
    private(set) var selectedQuality: VideoQuality = .medium {
        didSet {
            updateSelection()
        }
    }
    
    private let lowQuality = QualityItem(title: "Low quality")
    private let mediumQuality = QualityItem(title: "Medium quality")
    private let highQuality = QualityItem(title: "High quality")
    
    private var allItems: [QualityItem] {
        [lowQuality, mediumQuality, highQuality]
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        addArrangedSubviews()
        setupItemCallbacks()
        selectInitialQuality()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension QualitySelector {
    func setQuality(_ quality: VideoQuality) {
        selectedQuality = quality
    }
}

private extension QualitySelector {
    func setupUI() {
        axis = .vertical
        backgroundColor = .clear
        spacing = 12
        distribution = .fillEqually
        alignment = .fill
    }
    
    func addArrangedSubviews() {
        allItems.forEach {
            addArrangedSubview($0)
        }
    }
    
    func setupItemCallbacks() {
        lowQuality.onTap = { [weak self] in
            self?.selectQuality(.low)
        }
        
        mediumQuality.onTap = { [weak self] in
            self?.selectQuality(.medium)
        }
        
        highQuality.onTap = { [weak self] in
            self?.selectQuality(.high)
        }
    }
    
    func selectInitialQuality() {
        selectedQuality = .medium
    }
    
    func selectQuality(_ quality: VideoQuality) {
        selectedQuality = quality
        onQualitySelected?(quality)
    }
    
    func updateSelection() {
        allItems.forEach { $0.isSelected = false }
        
        switch selectedQuality {
        case .low:
            lowQuality.isSelected = true
        case .medium:
            mediumQuality.isSelected = true
        case .high:
            highQuality.isSelected = true
        }
    }
}
