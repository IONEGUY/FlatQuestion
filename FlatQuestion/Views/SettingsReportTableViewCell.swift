import UIKit

class SettingsReportTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.setupShadow(cornerRadius: 0, shadowOpacity: 0.2, shadowRadius: 4.0, shadowOffsetHeight: 4)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension SettingsReportTableViewCell: ReuseIdentifierProtocol {
    static var identifier: String {
        return "SettingsReportTableViewCell"
    }
}
