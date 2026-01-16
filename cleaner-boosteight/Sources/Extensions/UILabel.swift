import UIKit

extension UILabel {
    func setTexts(semibold: String, regular: String, fontSize: CGFloat = 16, color: UIColor = .white) {
        let attributedString = NSMutableAttributedString()
        
        let boldPart = NSAttributedString(
            string: semibold + " ",
            attributes: [
                .font: UIFont.systemFont(ofSize: fontSize, weight: .semibold),
                .foregroundColor: color
            ]
        )
        
        let regularPart = NSAttributedString(
            string: regular,
            attributes: [
                .font: UIFont.systemFont(ofSize: fontSize, weight: .regular),
                .foregroundColor: color
            ]
        )
        
        attributedString.append(boldPart)
        attributedString.append(regularPart)
        
        self.attributedText = attributedString
    }
}
