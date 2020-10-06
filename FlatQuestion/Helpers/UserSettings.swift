import UIKit

class UserSettings {
    
    private enum SettingsKeys: String {
        case appUser
    }
    
    static var appUser: AppUser? {
        get {
            guard let savedData = UserDefaults.standard.object(forKey: SettingsKeys.appUser.rawValue) as? Data,
            let decodedModel = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedData) as? AppUser else { return nil }
            return decodedModel
        }
        set {
            let defaults = UserDefaults.standard
            let key = SettingsKeys.appUser.rawValue
            
            if let userModel = newValue {
                if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: userModel, requiringSecureCoding: false) {
                    defaults.set(savedData, forKey: key)
                } else {
                    defaults.removeObject(forKey: key)
                }
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    class func clearAppUser() {
        appUser = nil
    }
}
