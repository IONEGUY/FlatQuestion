import Foundation
import UIKit

protocol Closable {
    func close()
}

extension UIViewController: Closable {
    func close() {
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
