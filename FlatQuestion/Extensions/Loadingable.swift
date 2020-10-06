import Foundation
import UIKit

protocol Loadingable {
    func showLoadingIndicator()
    func hideLoadingableIndicator()
}

extension UIViewController: Loadingable {
    
    func showLoadingIndicator() {
        LoadingUtils.showActivityIndicator(view: view, targetVC: self)
    }
    
    func hideLoadingableIndicator() {
        LoadingUtils.hideActivityIndicator(view: view)
    }
    
}
