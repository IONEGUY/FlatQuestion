import UIKit

class CommentTableViewCell: UITableViewCell {
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var createdAt: UILabel!
    @IBOutlet weak var commentText: UILabel!
    @IBOutlet weak var rateView: UIView!
    @IBOutlet weak var bottonSpacing: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func fillData(_ comment: Comment?) {
        fullName.text = comment?.creatorName ?? String.empty
        commentText.text = comment?.text
        createdAt.text = DateTimeConverterHelper
            .convert(date: comment?.createdAt.date() ?? Date(), toFormat: "dd.MM.yyyy")
        setRate(comment?.rate ?? 1)
    }
    
    private func setRate(_ rate: Int) {
            let stars = self.rateView.subviews;
        for index in (0...4) {
            (stars[index] as? UIImageView)?.tintColor = UIColor.init(hex: "#8F8F8F")
        }
            for index in (0...rate - 1) {
                (stars[4 - index] as? UIImageView)?.tintColor = UIColor.init(hex: "#EAAB09")
            }

    }
}
