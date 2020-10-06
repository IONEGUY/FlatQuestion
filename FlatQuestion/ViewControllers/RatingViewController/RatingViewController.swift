import UIKit

protocol RatingViewControllerProtocol: AnyObject {
    func addButtonPressed()
    func declineButtonPressed()
}
class RatingViewController: UIViewController {

    @IBOutlet weak var writeMessageLabel: UILabel!
    @IBOutlet weak var addCommentLabel: UILabel!
    var rating: Int = 1
    @IBOutlet weak var messageTextView: UITextView!
    var user: AppUser?
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var addButton: DarkGradientButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var writeMessageView: UIView!
    @IBOutlet var starts: [UIImageView]!
    override func viewDidLoad() {
        super.viewDidLoad()

        setupStartGesture()
        setupView()
        localize()
    }
    weak var delegate: RatingViewControllerProtocol?

    func localize() {
        writeMessageLabel.text = "Добавить отзыв".localized
        addCommentLabel.text = "Написать сообщение".localized
        declineButton.setTitle("Отмена".localized, for: .normal)
        addButton.setTitle("Добавить".localized, for: .normal)
    }
    init(delegate: RatingViewControllerProtocol?, user: AppUser) {
        super.init(nibName: String(describing: RatingViewController.self), bundle: nil)
        self.modalPresentationStyle = .custom
        self.delegate = delegate
        self.user = user
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        declineButton.addCorner(with: 20, with: .black)
        writeMessageView.addCorner(with: 10, with: .black)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapOutContent(_:))))
    }

    func setupStartGesture() {
        var counter = 0
        starts.forEach { (imageView) in
            imageView.tag = counter
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.starTapped(_:))))
            counter += 1
        }
    }
    
    @objc func starTapped(_ sender: UITapGestureRecognizer? = nil) {
        guard let tagOfStar = sender?.view?.tag else { return }
        setStarsFilled(count: tagOfStar)
        self.rating = tagOfStar + 1
    }
    
    @objc func tapOutContent(_ sender: UITapGestureRecognizer? = nil) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setStarsFilled(count: Int) {
        starts.forEach { (imageView) in
            imageView.image = imageView.tag <= count ? UIImage(named: "star-filled") : UIImage(named: "star")
        }
    }
    
    @IBAction func declineButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.declineButtonPressed()
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        FireBaseHelper().createComment(comment: Comment(forUserId: user?.id ?? "", text: messageTextView.text, createdAt: Date().timeIntervalSince1970, rate: rating, creatorName: UserSettings.appUser?.fullName ?? "")) { (result) in
            print()
        }
        delegate?.addButtonPressed()
    }
    
}
