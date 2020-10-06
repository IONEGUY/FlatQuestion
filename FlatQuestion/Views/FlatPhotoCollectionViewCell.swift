import UIKit

protocol PhotoCellProtocol: class {
    func crossButtonWasPressed(imageNumber index: Int?)
}

class FlatPhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet weak var image: UIImageView!
    var imageNumber: Int?
    
    weak var delegate: PhotoCellProtocol?
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setCancelButtonHidden(hidden: Bool) {
        deleteButton.isHidden = hidden
    }
    @IBAction func deleteButtonPressed(_ sender: Any) {
        delegate?.crossButtonWasPressed(imageNumber: imageNumber)
    }
    
}

extension FlatPhotoCollectionViewCell: ReuseIdentifierProtocol {
    static var identifier: String {
        return String(describing: self)
    }
}
