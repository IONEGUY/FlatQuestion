import UIKit

class DateFormatterHelper: NSObject {

    let dateFormatter = DateFormatter()
    
    func getDateFrom_dd_MM_yyyy_HH_mm(dateString: String) -> Date? {
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        return dateFormatter.date(from: dateString)
    }
    
    func getStringFromDate_dd_MM_yyyy_HH_mm(date: Date) -> String? {
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        return dateFormatter.string(from: date)
    }
    
    func getStringFromDate_MMM_yyyy_HH_mm(date: Date) -> String? {
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
        return dateFormatter.string(from: date)
    }
    
    func getStringFromDate_MMM_yyyy(date: Date) -> String? {
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter.string(from: date)
    }
}
 
