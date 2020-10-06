import Foundation
import UIKit
import Lottie

class LoadingUtils {
    static func showActivityIndicator(view: UIView, targetVC: UIViewController) {

        let animationView = AnimationView(name: "loading-2")
        animationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        animationView.center = targetVC.view.center
        view.addSubview(animationView)
        animationView.loopMode = .loop
        animationView.tag = 10001
        animationView.play()
//        var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
//
//        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
//        activityIndicator.backgroundColor = UIColor(red:0.16, green:0.17, blue:0.21, alpha:1)
//        activityIndicator.layer.cornerRadius = 6
//        activityIndicator.center = targetVC.view.center
//        activityIndicator.hidesWhenStopped = true
//        activityIndicator.style = .whiteLarge
//        activityIndicator.tag = 1
//        view.addSubview(activityIndicator)
//        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }

    static func hideActivityIndicator(view: UIView) {
        let animatingView = view.viewWithTag(10001) as? AnimationView
        animatingView?.stop()
        animatingView?.removeFromSuperview()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
}
