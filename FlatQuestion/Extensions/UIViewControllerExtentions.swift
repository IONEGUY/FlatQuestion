import Foundation
import UIKit
extension UIViewController {
    func topMostViewController() -> UIViewController {
        
        
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        
        return self
    }
}
