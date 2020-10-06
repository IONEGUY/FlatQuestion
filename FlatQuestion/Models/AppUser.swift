import UIKit

class AppUser: NSObject, NSCoding, Codable {
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(fullName, forKey: "fullName")
        coder.encode(email, forKey: "email")
        coder.encode(avatarUrl, forKey: "avatarUrl")
        coder.encode(sex, forKey: "sex")
        coder.encode(date, forKey: "date")
        coder.encode(x, forKey: "x")
        coder.encode(y, forKey: "y")
        coder.encode(location, forKey: "location")
        coder.encode(aboutMe, forKey: "aboutMe")
        coder.encode(vkLink, forKey: "vkLink")
        coder.encode(instLink, forKey: "instLink")
        coder.encode(flats, forKey: "flats")
    }
    
    required init?(coder: NSCoder) {
        id = coder.decodeObject(forKey: "id") as? String ?? ""
        fullName = coder.decodeObject(forKey: "fullName") as? String ?? ""
        email = coder.decodeObject(forKey: "email") as? String ?? ""
        avatarUrl = coder.decodeObject(forKey: "avatarUrl") as? String ?? ""
        
        sex = coder.decodeObject(forKey: "sex") as? Bool
        date = coder.decodeObject(forKey: "date") as? TimeInterval
        x = coder.decodeObject(forKey: "x") as? Double
        y = coder.decodeObject(forKey: "y") as? Double
        location = coder.decodeObject(forKey: "location") as? String
        aboutMe = coder.decodeObject(forKey: "aboutMe") as? String
        vkLink = coder.decodeObject(forKey: "vkLink") as? String
        instLink = coder.decodeObject(forKey: "instLink") as? String
        flats = coder.decodeObject(forKey: "flats") as? [Int]
    }
    
    init(id: String?, fullName: String?, email: String?, avatarUrl: String?) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.avatarUrl = avatarUrl
    }
    
    var id: String?
    var fullName: String?
    var email: String?
    var avatarUrl: String?
    
    var sex: Bool?
    var date: TimeInterval?
    var x: Double?
    var y: Double?
    var location: String?
    var aboutMe: String?
    var vkLink: String?
    var instLink: String?
    var flats: [Int]?
    
    
    var asDictionary : [String:Any] {
      let mirror = Mirror(reflecting: self)
      let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
        guard let label = label else { return nil }
        return (label, value)
      }).compactMap { $0 })
      return dict
    }
}
