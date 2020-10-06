import UIKit

class LoadingCell: UITableViewCell {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        spinner.color = UIColor.black
    }
    
    func setMessage(_ message: String) {
        self.messageLabel.text = message
    }
    
    func changeSpinnerStatus(isRunning: Bool) {
        isRunning ? spinner.startAnimating() : spinner.stopAnimating()
    }
}
