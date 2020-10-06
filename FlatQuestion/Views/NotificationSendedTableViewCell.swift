import UIKit

class NotificationSendedTableViewCell: UITableViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setup(photo: URL, name: String, time: String) {
        self.photoImageView.sd_setImage(with: photo, completed: nil)
        nameLabel.text = name
        
    }

}

extension NotificationSendedTableViewCell: ReuseIdentifierProtocol {
    static var identifier: String {
        get {
            return "NotificationSendedTableViewCell"
        }
    }
}
