import UIKit
import Lottie
protocol AnimatedLaunchProtocol: AnyObject {
    func willClose()
}
class AnimatedLaunchViewController: UIViewController {
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var logoLabel: UILabel!
    weak var delegate: AnimatedLaunchProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        
//beginAnimation()

//        let animationView = AnimationView(name: "sok")
//        animationView.frame = CGRect(x: -20, y: 200, width: self.view.frame.width, height: 200)
//        self.view.layoutIfNeeded()
//        animationView.frame = CGRect(x: 0, y: 200, width: self.view.frame.width, height: 300)
//        animationView.center = self.view.center
        
//        animationView.contentMode = .scaleAspectFit
//        self.view.addSubview(animationView)
//        animationView.play { (finished) in
//            self.delegate?.willClose()
//        }
    }
    
//    func beginAnimation () {
//
//        UIView.animate(withDuration: 0.8, delay:0, options: [.repeat, .autoreverse], animations: {
//            UIView.setAnimationRepeatCount(3)
//            self.logoLabel.alpha = 1.0
//            }, completion: {completion in
//                self.delegate?.willClose()
//        })
//
//
//    }
    override func viewDidAppear(_ animated: Bool) {
        self.delegate?.willClose()
    }
}


