import UIKit
import SnapKit

final class MediaGroupCell: UITableViewCell {
    static let reuseIdentifier = "MediaGroupCell"
    
    private let containerView = UIView()
    
    private lazy var viewAllContainer = {
        let label = UILabel()
        label.text = "View all"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = Colors.secondaryGray
        label.numberOfLines = 0
        
        let icon = UIImageView(image: .arrowRight)
        icon.contentMode = .scaleAspectFit
        
        $0.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.verticalEdges.equalToSuperview()
        }

        $0.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(label)
            make.leading.equalTo(label.snp.trailing).offset(10.67)
        }
        
        return $0
    }(UIView())
    
    private let titleLabel = {
        $0.font = Fonts.Montserrat.semiBold20
        $0.textColor = Colors.primaryBlack
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    private let mediaCountLabel = {
        $0.numberOfLines = 0
        $0.textColor = Colors.secondaryGray
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        return $0
    }(UILabel())
    
    private let iconImageView = {
        $0.contentMode = .scaleAspectFill
        $0.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        return $0
    }(UIImageView())
    
    private let previewImageView = {
        $0.contentMode = .scaleAspectFill
        $0.snp.makeConstraints { make in
            make.height.equalTo(155)
        }
        return $0
    }(UIImageView())
    
    private let lockImageView = {
        $0.contentMode = .scaleAspectFit
        $0.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        return $0
    }(UIImageView(image: .lockIcon))
    
    private let loadingIndicator = {
        $0.style = .medium
        $0.hidesWhenStopped = true
        $0.color = .black
        return $0
    }(UIActivityIndicatorView())
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MediaGroupCell {
    func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    func setupConstraints() {
        contentView.addSubview(containerView)
        
        containerView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().inset(16)
        }
        
        setupContainerViewConstraints()
    }
    
    func setupContainerViewConstraints() {
        [iconImageView, titleLabel, mediaCountLabel,
         previewImageView, lockImageView, viewAllContainer, loadingIndicator].forEach {
            containerView.addSubview($0)
        }
        
        iconImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(8)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(16)
            $0.top.equalTo(iconImageView)
        }
        
        mediaCountLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(8)
            $0.leading.equalTo(iconImageView)
        }
        
        lockImageView.snp.makeConstraints {
            $0.top.equalTo(iconImageView)
            $0.trailing.equalToSuperview().inset(8)
        }
        
        viewAllContainer.snp.makeConstraints {
            $0.top.equalTo(mediaCountLabel)
            $0.trailing.equalToSuperview().inset(14)
        }
        
        loadingIndicator.snp.makeConstraints {
            $0.leading.equalTo(mediaCountLabel.snp.trailing).offset(8)
            $0.centerY.equalTo(mediaCountLabel)
        }
        
        previewImageView.snp.makeConstraints {
            $0.top.equalTo(mediaCountLabel.snp.bottom).offset(21)
            $0.horizontalEdges.equalToSuperview().inset(12.5)
            $0.bottom.equalToSuperview().inset(8)
        }
        
    }
}

private extension MediaGroupCell {
    func makeMediaInfoText(
        count: Int?,
        size: String?
    ) -> NSAttributedString {
        
        let result = NSMutableAttributedString()
        
        let primaryAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            .foregroundColor: Colors.secondaryGray
        ]
        
        let secondaryAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            .foregroundColor: Colors.secondaryGray
        ]
        
        result.append(
            NSAttributedString(
                string: "\(count ?? 0) Media",
                attributes: primaryAttributes
            )
        )
        
        if let size = size {
            result.append(
                NSAttributedString(
                    string: " • ",
                    attributes: secondaryAttributes
                )
            )
            
            result.append(
                NSAttributedString(
                    string: "\(size) GB",
                    attributes: secondaryAttributes
                )
            )
        }
        
        return result
    }
}

extension MediaGroupCell {
    func configure(with model: MediaGroupModel) {
        titleLabel.text = model.type.title
        
        if model.isLoading {
            loadingIndicator.startAnimating()
            mediaCountLabel.attributedText = makeMediaInfoText(
                count: model.mediaCount,
                size: nil
            )
        } else {
            loadingIndicator.stopAnimating()
            mediaCountLabel.attributedText = makeMediaInfoText(
                count: model.mediaCount,
                size: String(format: "%.1f", model.mediaSize)
            )
        }
        
        iconImageView.image = model.type.image
        previewImageView.image = model.type.previewImage
        viewAllContainer.isHidden = model.type == .videoCompressor ? true : false
        lockImageView.isHidden = !model.isLocked
    }
}
