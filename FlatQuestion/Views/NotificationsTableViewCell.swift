import UIKit
import SDWebImage
protocol NotificationsTableViewCellProtocol: AnyObject {
    func statusOfRequestWasChanged(result: Result<Void,Error>, userId: String)
}

class NotificationsTableViewCell: UITableViewCell {

    weak var delegate: NotificationsTableViewCellProtocol?
    @IBOutlet weak var approveButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var photoImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    @IBAction func btn(_ sender: Any) {
    }
    
    var flatId: Int!
    var userInfo: UserInfo!
    
    func setupCell(flatId: Int, userInfo: UserInfo) {
        fullNameLabel.text = userInfo.fullName
        photoImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
        photoImage.sd_setImage(with: URL(string: userInfo.photoLink)!, completed: nil)
        messageLabel.text = userInfo.message
        declineButton.addCorner(with: 20, with: .black)
        modify(status: userInfo.status)
        
        self.flatId = flatId
        self.userInfo = userInfo
        
    }
    
    @IBAction func declineButtonPressed(_ sender: Any) {
            self.userInfo.status = .Declined
            FireBaseHelper().updateFlatRequestStatus(flatId: self.flatId, userInformation: self.userInfo) { (result) in
                self.delegate?.statusOfRequestWasChanged(result: result, userId: self.userInfo.id)
            }
//            FireBaseHelper().removeFlatRequestUserInfo(flatId: self.flatId, userInformation: self.userInfo) { (result) in
//                self.delegate?.statusOfRequestWasChanged(result: result)
//            }
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let padding = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        bounds.inset(by: padding)
    }
    
    @IBAction func approveRequest(_ sender: Any) {
        if userInfo.status == .Approved {
            userInfo.status = .New
            FireBaseHelper().updateFlatRequestStatus(flatId: self.flatId, userInformation: self.userInfo) { (result) in
                self.delegate?.statusOfRequestWasChanged(result: result, userId: self.userInfo.id)
            }
        } else if userInfo.status == .New {
        userInfo.status = .Approved
        FireBaseHelper().updateFlatRequestStatus(flatId: self.flatId, userInformation: self.userInfo) { (result) in
            self.delegate?.statusOfRequestWasChanged(result: result, userId: self.userInfo.id)
        }
//        DispatchQueue.main.async {
//            self.approveButton.setTitle("Принято".localized, for: .normal)
//            self.approveButton.removeSublayers()
//            self.layoutSubviews()
//            self.approveButton.addCorner(with: 20, with: .black)
//            self.approveButton.setTitleColor(UIColor(hex: 0x8F8F8F), for: .normal)
//            self.approveButton.backgroundColor = .white
//
//             self.declineButton.setAttributedTitle(NSAttributedString(string: "Удалить".localized, attributes: [NSAttributedString.Key.font: UIFont(name: "SFProDisplay-Regular", size: 15.0), NSAttributedString.Key.foregroundColor: UIColor(hex: 0xF11616)]), for: .normal)
//             self.descriptionLabel.text = "добавлен(а) к участникам вечеринке".localized
//            self.layoutSubviews()
//        }
        }}
    
    
    func modify(status: RequestStatus) {
        self.declineButton.setAttributedTitle(NSAttributedString(string: "Удалить".localized, attributes: [NSAttributedString.Key.font: UIFont(name: "SFProDisplay-Regular", size: 15.0), NSAttributedString.Key.foregroundColor: UIColor(hex: 0xF11616)]), for: .normal)
        switch status {
        case .New:
            DispatchQueue.main.async {
            self.approveButton.setTitle("Принять".localized, for: .normal)
            self.approveButton.setTitleColor(.white, for: .normal)
                self.approveButton.backgroundColor = UIColor(hex: 0x03CCE0)
                
                self.approveButton.addShadow(shadowColor: UIColor(hex: 0x03CCE0).cgColor,
                                 shadowOffset: CGSize(width: 5, height: 10),
                                 shadowOpacity: 0.2,
                                 shadowRadius: 10.0)
//            self.declineButton.setAttributedTitle(NSAttributedString(string: "Отказать".localized, attributes: [NSAttributedString.Key.font: UIFont(name: "SFProDisplay-Regular", size: 15.0), NSAttributedString.Key.foregroundColor: UIColor(hex: 0x5B58B4)]), for: .normal)
            self.descriptionLabel.text = "желает присоединиться к вечеринке".localized
            //self.approveButton.applyGradientV2(colours: [UIColor(hexString: "0x615CBF")!, UIColor(hexString: "0x1C2F4B")!])
            self.approveButton.titleLabel?.font = UIFont(name: "SFProDisplay-Regular", size: 16)
            self.approveButton.layer.cornerRadius = 20
            //self.approveButton.clipsToBounds = true
            }
            
        case .Approved:
            DispatchQueue.main.async {
            self.approveButton.setTitle("Отказать".localized, for: .normal)
            self.approveButton.removeSublayers()
            self.approveButton.addCorner(with: 20, with: .black)
            self.approveButton.setTitleColor(UIColor(hex: 0x8F8F8F), for: .normal)
            self.approveButton.backgroundColor = .white

             self.descriptionLabel.text = "добавлен(а) к участникам вечеринке".localized
            }
            
        default:
            print("Declined")
        }
    }
    
}

extension NotificationsTableViewCell: ReuseIdentifierProtocol {
    static var identifier: String {
        get {
            return "NotificationsTableViewCell"
        }
    }
}
