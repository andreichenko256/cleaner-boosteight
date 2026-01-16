import UIKit
import SnapKit

class CircularProgressView: UIView {
    var progress: CGFloat = 0 {
        didSet {
            updateProgress()
        }
    }
    
    var lineWidth: CGFloat = 15 {
        didSet {
            setupLayers()
        }
    }
    
    var backgroundProgressColor = Colors.bgProgressColor {
        didSet {
            backgroundLayer.strokeColor = backgroundProgressColor.cgColor
        }
    }
    
    var progressColor: UIColor = Colors.progressColor {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    private let backgroundLayer = {
        $0.fillColor = UIColor.clear.cgColor
        $0.lineCap = .round
        return $0
    }(CAShapeLayer())
    
    private let progressLayer = {
        $0.fillColor = UIColor.clear.cgColor
        $0.lineCap = .round
        $0.strokeEnd = 0
        return $0
    }(CAShapeLayer())
    
    private let percentageLabel = {
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 24, weight: .semibold)
        $0.textColor = Colors.primaryWhite
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    private let descriptionLabel = {
        $0.text = "used"
        $0.font = .systemFont(ofSize: 13, weight: .regular)
        $0.textColor = Colors.primaryWhite
        $0.numberOfLines = 0
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    private let containerView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - lineWidth / 2
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + 2 * CGFloat.pi
        
        let circularPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        
        backgroundLayer.path = circularPath.cgPath
        progressLayer.path = circularPath.cgPath
    }
}

private extension CircularProgressView {
    func setupUI() {
        backgroundColor = .clear
        
        setupLayers()
        setupLabels()
    }
    
    func setupLayers() {
        backgroundLayer.strokeColor = backgroundProgressColor.cgColor
        backgroundLayer.lineWidth = lineWidth
        layer.addSublayer(backgroundLayer)
        setupShadow(for: backgroundLayer)
        
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = lineWidth
        layer.addSublayer(progressLayer)
    }
    
    func setupLabels() {
        addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        setupContrainerViewConstraints()
    }
    
    func setupContrainerViewConstraints() {
        [percentageLabel, descriptionLabel].forEach {
            containerView.addSubview($0)
        }
        
        percentageLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(percentageLabel.snp.bottom).offset(2)
            $0.horizontalEdges.equalTo(percentageLabel)
            $0.bottom.equalToSuperview()
        }
    }
    
    func updateProgress() {
        progressLayer.strokeEnd = progress
        percentageLabel.text = "\(Int(progress * 100))%"
    }
    
    func setupShadow(for layer: CAShapeLayer) {
        layer.shadowColor = UIColor(red: 86/255, green: 147/255, blue: 249/255, alpha: 1).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 13.9 / 2
        layer.shadowOpacity = 1
        layer.masksToBounds = false
    }
}

extension CircularProgressView {
    func setProgress(_ value: CGFloat, animated: Bool = true, duration: TimeInterval = 1.0) {
        progress = min(max(value, 0), 1)
        
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = progressLayer.strokeEnd
            animation.toValue = progress
            animation.duration = duration
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            progressLayer.add(animation, forKey: "progressAnimation")
        }
        
        progressLayer.strokeEnd = progress
        percentageLabel.text = "\(Int(progress * 100))%"
    }
}
