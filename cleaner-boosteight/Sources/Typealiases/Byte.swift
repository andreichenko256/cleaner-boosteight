import Foundation

typealias Byte = UInt64

extension Byte {
    var formattedBytes: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB]
        formatter.countStyle = .file
        formatter.allowsNonnumericFormatting = false
        return formatter.string(fromByteCount: Int64(self))
    }
    
    var formattedBytesRounded: String {
        let formatter = ByteFormatter()
        return formatter.string(fromByteCount: self, digits: 0)
    }
    
    func formattedBytesRounded(to digits: Int) -> String {
        let formatter = ByteFormatter()
        return formatter.string(fromByteCount: self, digits: digits)
    }
}

private struct ByteFormatter {
    func string(fromByteCount count: UInt64, digits: Int = 2) -> String {
        
        let measurement = Measurement(value: Double(count), unit: UnitInformationStorage.bytes)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = digits
        numberFormatter.minimumFractionDigits = 0
        
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .naturalScale
        formatter.unitStyle = .medium
        formatter.numberFormatter = numberFormatter
        
        let string = formatter.string(from: measurement).replacing(",", with: ".")
        
        return string
    }
}
