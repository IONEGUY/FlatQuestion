import UIKit

class SettingsLanguageTableViewCell: UITableViewCell {

    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var languageKindLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        languageLabel.text = "Язык".localized
        self.setupShadow(cornerRadius: 0, shadowOpacity: 0.2, shadowRadius: 4.0, shadowOffsetHeight: 4)
    }
    
}

extension SettingsLanguageTableViewCell: ReuseIdentifierProtocol {
    static var identifier: String {
        return "SettingsLanguageTableViewCell"
    }
}
