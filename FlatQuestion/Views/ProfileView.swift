import Foundation
import UIKit

protocol ProfileViewProtocol: AnyObject {
    func didButtonPressed()
    func settingsButtonPressed()
}

class ProfileView: UIView {
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var genderAndYearsLabel: UILabel!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var writeMessageButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var smallView: UIView!
    @IBOutlet weak var smallFullNameLabel: UILabel!
    @IBOutlet weak var smallGenderAndYearsLabel: UILabel!
    @IBOutlet weak var smallLocationLabel: UILabel!
    @IBOutlet weak var smallProfileView: UIImageView!
    @IBOutlet weak var locationView: UIView!
    
    weak var delegate: ProfileViewProtocol?
    
    var isSmallView = false
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    private func loadFromNib() {
        let bundle = Bundle.init(for: type(of: self))
        let nib = UINib(nibName: "ProfileView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        view!.frame = bounds
        view!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view!)
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        delegate?.settingsButtonPressed()
    }
    
    private func setupView() {
        loadFromNib()
    }
    
    @IBAction func buttonDidPressed(_ sender: Any) {
        delegate?.didButtonPressed()
    }
    
    func showSmallView() {
        //guard !self.isSmallView else { return }
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
            self.locationView.alpha = 0
            self.genderAndYearsLabel.alpha = 0
            self.fullName.alpha = 0
            self.isSmallView = true
            self.layoutSubviews()
            self.updateConstraints()
        } completion: { (finished) in
            UIView.animate(withDuration: 0.2) {
                self.smallView.alpha = 1
            }
        }

//        UIView.animate(withDuration: 0.6) {
//            self.smallView.alpha = 1
//            self.locationView.alpha = 0
//            self.genderAndYearsLabel.alpha = 0
//            self.fullName.alpha = 0
//            self.isSmallView = true
//            self.layoutSubviews()
//            self.updateConstraints()
//        }
    }
    
    func hideSmallView() {
        //guard isSmallView else { return }
        UIView.animate(withDuration: 0.1) {
            self.smallView.alpha = 0
            self.locationView.alpha = 1
            self.genderAndYearsLabel.alpha = 1
            self.fullName.alpha = 1
            self.isSmallView = false
            self.layoutSubviews()
        }
    }
}
