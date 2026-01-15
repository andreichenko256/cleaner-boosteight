import UIKit
import SnapKit

final class PageControlView: UIView {
    private var dots: [UIView] = []
    
    private let dotSize: CGFloat = 8
    
    var numberOfPages: Int = 3 {
        didSet {
            setupDots()
        }
    }
    
    var currentPage: Int = 0 {
        didSet {
            updateDots()
        }
    }
    
    private var cornerRadius: CGFloat {
        dotSize / 2
    }
    
    private let stackView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 4
        return $0
    }(UIStackView())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
        setupDots()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension PageControlView {
    func setupConstraints() {
       addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(dotSize)
        }
    }
    
    func setupDots() {
        dots.forEach { $0.removeFromSuperview() }
        dots.removeAll()
        
        for _ in 0..<numberOfPages {
            let dot = createDot()
            dots.append(dot)
            stackView.addArrangedSubview(dot)
        }
        
        updateDots()
    }
    
    func createDot() -> UIView {
        let dot = UIView() 
        dot.backgroundColor = Colors.inactiveDot
        dot.layer.cornerRadius = cornerRadius
        dot.clipsToBounds = true
        return dot
    }
    
    func updateDots() {
        for (index, dot) in dots.enumerated() {
            let isActive = index == currentPage
            let targetColor = isActive ? Colors.primaryBlue : Colors.inactiveDot
            dot.backgroundColor = targetColor
            dot.snp.makeConstraints {
                $0.height.equalTo(dotSize)
                $0.width.equalTo(isActive ? dotSize * 2 : dotSize)
            }
        }
    }
}
