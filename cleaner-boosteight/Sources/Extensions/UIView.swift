import UIKit
import SnapKit

extension UIView {
    var safeTop: ConstraintItem { safeAreaLayoutGuide.snp.top }
    var safeBottom: ConstraintItem { safeAreaLayoutGuide.snp.bottom }
    var safeLeading: ConstraintItem { safeAreaLayoutGuide.snp.leading }
    var safeTrailing: ConstraintItem { safeAreaLayoutGuide.snp.trailing }
}
