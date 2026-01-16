import Foundation

final class ByteSizeFormatter {
    static func format(_ bytes: UInt64) -> String {
        let units = ["bytes", "KB", "MB", "GB", "TB"]
        var size = Double(bytes)
        var unitIndex = 0
        
        while size >= 1024 && unitIndex < units.count - 1 {
            size /= 1024
            unitIndex += 1
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 1
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.decimalSeparator = "."
        numberFormatter.groupingSeparator = ""
        
        guard let formattedNumber = numberFormatter.string(from: NSNumber(value: size)) else {
            return "\(Int(size)) \(units[unitIndex])"
        }
        
        return "\(formattedNumber) \(units[unitIndex])"
    }
}
