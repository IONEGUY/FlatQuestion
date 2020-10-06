import UIKit

protocol ModalPopUpViewControllerProtocol: AnyObject  {
    func createButtonPressed()
}

class ModalPopUpViewController: UIViewController {

    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var createButton: DarkGradientButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    weak var delegate: ModalPopUpViewControllerProtocol?
    var titleString: String?
    var descriptionString: String?
    var createButtonString: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        localize()
    }

    init(delegate: ModalPopUpViewControllerProtocol?, title: String?, description: String?, createButtonText: String?) {
          super.init(nibName: String(describing: ModalPopUpViewController.self), bundle: nil)
        titleString = title
        descriptionString = description
        createButtonString = createButtonText
          self.modalPresentationStyle = .custom
          self.delegate = delegate
      }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
        private func localize() {
            createButton.setTitle(createButtonString, for: .normal)
            createButton.titleLabel?.text = createButtonString?.localized
            declineButton.titleLabel?.text = "Отмена".localized
            descriptionLabel.text = descriptionString?.localized
            titleLabel.text = titleString?.localized
        }
        
        private func setupView() {
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tap(_:))))
            view.isUserInteractionEnabled = true
            
            declineButton.addCorner(with: 20, with: .black)
        }
    
    @objc func tap(_ gestureRecognizer: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func declineButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func createButtonPressed(_ sender: UIButton) {
        delegate?.createButtonPressed()
        self.dismiss(animated: true, completion: nil)
    }
    
}

