import UIKit

protocol QuestionModalViewControllerProtocol: AnyObject {
    func acceptButtonPressed()
}

class QuestionModalViewController: UIViewController {
    weak var delegate: QuestionModalViewControllerProtocol?
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var createButton: DarkGradientButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var declineButton: UIButton!
    
    private var titleText: String?
    private var questionText: String?
    private var acceptButtonText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        // Do any additional setup after loading the view.
    }

    func setupView() {
        declineButton.addCorner(with: 20, with: .black)
        popUpView.addCorner(with: 10, with: .black)
        
        titleLabel.text = titleText
        questionLabel.text = questionText
        createButton.setTitle(acceptButtonText, for: .normal)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tap(_:))))
        self.view.isUserInteractionEnabled = true
    }
    
    @objc func tap(_ gestureRecognizer: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    init(delegate: QuestionModalViewControllerProtocol?, titleText: String, questionText: String, acceptButtonText: String) {
        self.titleText = titleText
        self.questionText = questionText
        self.acceptButtonText = acceptButtonText
        super.init(nibName: String(describing: QuestionModalViewController.self), bundle: nil)
        self.modalPresentationStyle = .custom
        self.delegate = delegate
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func declineButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func acceptButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.acceptButtonPressed()
    }
    
}

extension QuestionModalViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented is AcceptModalViewController {
            return TransparentBackgroundModalPresenter(isPush: true, originFrame: UIScreen.main.bounds)
        } else {
        return SuccessModalPresenter(isPush: true, originFrame: UIScreen.main.bounds)
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed is AcceptModalViewController {
        return TransparentBackgroundModalPresenter(isPush: false)
        } else {
            return SuccessModalPresenter(isPush: false)
        }
    }
}
