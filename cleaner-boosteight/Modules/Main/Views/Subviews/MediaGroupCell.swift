import UIKit
import SnapKit

final class MediaGroupCell: UITableViewCell {
    static let reuseIdentifier = "MediaGroupCell"
    
    private let containerView = UIView()
    
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
        [iconImageView, titleLabel, mediaCountLabel, iconImageView].forEach {
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
        
        iconImageView.snp.makeConstraints {
            $0.top.equalTo(mediaCountLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(12.5)
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
            .foregroundColor: Colors.primaryBlack
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
        
        result.append(
            NSAttributedString(
                string: " • ",
                attributes: secondaryAttributes
            )
        )
        
        result.append(
            NSAttributedString(
                string: size ?? "0",
                attributes: secondaryAttributes
            )
        )
        
        return result
    }
}

extension MediaGroupCell {
    func configure(with model: MediaGroupModel) {
        titleLabel.text = model.title
        mediaCountLabel.attributedText = makeMediaInfoText(
            count: model.mediaCount,
            size: String(model.mediaSize)
        )
        iconImageView.image = model.image
    }
}
