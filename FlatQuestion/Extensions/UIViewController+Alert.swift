import Foundation
import UIKit

extension UIViewController {
    func showAlertWithMessage(message: String) {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        let alert = UIAlertController(title: "Ошибка".localized, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Отмена".localized, style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        let settingsAction = UIAlertAction(title: "Настройки".localized, style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
            UIApplication.shared.open(settingsUrl, options: [:]) { (success) in
                if success {
                    print("Settings opened: \(success)")
                }
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(settingsAction)
        self.present(alert, animated: true, completion: nil)
    }
}
