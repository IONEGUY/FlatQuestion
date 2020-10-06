import Foundation
import UIKit
class ThirdPartyApplicationOpenner {
    private let vkUrl = URL(string: "https://vk.com")!
    private let instUrl = URL(string: "https://instagram.com")!
    func openVKWithId(id: String?) {
        guard let id = id else { return }
        let appURL = URL(string: "vk://vk.com/id/\(id)") ?? vkUrl
        let safariURL = URL(string: "https://vk.com/\(id)") ?? vkUrl

        if UIApplication.shared.canOpenURL(appURL as URL){
            UIApplication.shared.open(appURL as URL, options: [:], completionHandler: nil)
        } else if UIApplication.shared.canOpenURL(safariURL as URL){
            UIApplication.shared.open(safariURL as URL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.open(vkUrl, options: [:], completionHandler: nil)
        }
    }
    
    func openInstagramWithId(id: String?) {
        guard let id = id else { return }
        let appURL = URL(string: "instagram://user?username=\(id))") ?? instUrl
        let safariURL = URL(string: "https://www.instagram.com/\(id)/") ?? instUrl
        if UIApplication.shared.canOpenURL(appURL as URL){
            UIApplication.shared.open(appURL as URL, options: [:], completionHandler: nil)
        } else if UIApplication.shared.canOpenURL(safariURL as URL){
            UIApplication.shared.open(safariURL as URL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.open(instUrl, options: [:], completionHandler: nil)
        }
    }
}
