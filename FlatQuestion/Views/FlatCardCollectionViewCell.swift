import UIKit
import SDWebImage
class FlatCardCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var placesLabel: UILabel!
    
    @IBOutlet weak var view: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func fillCellData(with flat: FlatModel) {
        if flat.userId == UserSettings.appUser!.id {
            titleLabel.textColor = UIColor(hex: 0xBC70F6)
            myLabel.textColor = UIColor(hex: 0xBC70F6)
            myLabel.isHidden = false
        } else {
            titleLabel.textColor = UIColor(hex: 0x03CCE0)
            myLabel.isHidden = true
        }
        view.backgroundColor = .white
        self.titleLabel.text = flat.name.capitalizingFirstLetter()
        setupViewOfAddressLabel(address: flat.address)
        dateLabel.text = DateFormatterHelper().getStringFromDate_MMM_yyyy_HH_mm(date: flat.date?.date() ?? Date())
        placesLabel.text = "Свободно".localized + " \(String(describing: flat.emptyPlacesCount!)) " + "из".localized + " \(String(describing: flat.allPlacesCount!))"
        guard let url = URL(string: (flat.images?[0])!) else {return}
        imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imageView.sd_setImage(with: url, completed: nil)
    }
}

//MARK: Private methods
extension FlatCardCollectionViewCell {
    private func setupViewOfAddressLabel(address: String) {
        let attributedString = NSMutableAttributedString(string: address)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        addressLabel.attributedText = attributedString
    }

}

extension FlatCardCollectionViewCell: ReuseIdentifierProtocol {
    static var identifier: String {
        return String(describing: self)
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
