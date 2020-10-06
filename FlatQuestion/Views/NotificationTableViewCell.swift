import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setup(photo: URL, name: String, time: String, status: RequestStatus) {
        self.photoImageView.sd_setImage(with: photo, completed: nil)
        nameLabel.text = name
        timeLabel.text = time
        
        switch status {
        case .Approved: statusLabel.text = "Вашу заявку приняли".localized
        case .New: statusLabel.text = "Ваша заявка была отправлена".localized
        case .Declined: statusLabel.text = "Вашу заявку отклонили".localized
        }
        
    }
    
}

extension NotificationTableViewCell: ReuseIdentifierProtocol {
    static var identifier: String {
        get {
            return "NotificationTableViewCell"
        }
    }
}
