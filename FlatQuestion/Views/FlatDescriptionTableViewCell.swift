import UIKit

class FlatDescriptionTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupTitle(title: String, description: String) {
        self.titleLabel.text = title
        self.descriptionLabel.text = description
    }
    
}

extension FlatDescriptionTableViewCell: ReuseIdentifierProtocol {
    static var identifier: String {
        return String(describing: self)
    }
}
