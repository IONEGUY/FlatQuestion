import UIKit

class OutgoingMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var messageSentTime: UILabel!
    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var messageTextContainer: UIView!
    @IBOutlet weak var statusMarkerImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.clear
        selectedBackgroundView = backgroundView
        messageTextContainer.layer.cornerRadius = 10;
        messageTextContainer.layer.borderWidth = 1.5;
        messageTextContainer.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
    }
    
    public func initialize(withData messageCellModel: MessageCellModel) {
        self.messageText.text = messageCellModel.messageText
        self.messageSentTime.text = messageCellModel.sentTime
        
        showAppropriateStatus(messageCellModel.sentSuccessfully ?? true)
    }
    
    private func showAppropriateStatus(_ sentSuccessfully: Bool) {
         statusMarkerImageView.image = sentSuccessfully
             ? UIImage(named: "success")
             : UIImage(systemName: "exclamationmark.triangle.fill")
    }
}
