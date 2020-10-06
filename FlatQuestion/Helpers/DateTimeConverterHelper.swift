import Foundation

class DateTimeConverterHelper {
    class func convert(date: Date, toFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
}
