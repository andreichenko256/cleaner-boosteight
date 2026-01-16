import Foundation

struct AlertModel {
    let title: String
    let message: String
    let primaryAction: AlertAction
    let secondaryAction: AlertAction?
    
    struct AlertAction {
        let title: String
        let style: ActionStyle
        let handler: (() -> Void)?
        
        enum ActionStyle {
            case `default`
            case cancel
            case openSettings
        }
    }
}
