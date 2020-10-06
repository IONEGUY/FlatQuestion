import Foundation
import UIKit

class TransparentBackgroundModalPresenter: NSObject, UIViewControllerAnimatedTransitioning {
    var duration: TimeInterval
    var isPush: Bool
    var originFrame: CGRect
    
    init(isPush: Bool, duration: TimeInterval = 0.3, originFrame: CGRect = .zero) {
        self.duration = duration
        self.isPush = isPush
        self.originFrame = originFrame
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch isPush {
        case true: animatePushTransition(using: transitionContext)
        case false: animatePopTransition(using: transitionContext)
        }
    }
}

private extension TransparentBackgroundModalPresenter {
    
       func animatePopTransition(using transitionContext: UIViewControllerContextTransitioning) {
           guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) else { return }
           
           UIView.animate(withDuration: 0.2, animations: {
               //fromView.alpha = 0
               fromView.backgroundColor = UIColor.black.withAlphaComponent(0)
           }, completion: { (finished) in
               UIView.animate(withDuration: 0.2, animations: {
                   var frame = UIScreen.main.bounds
                   frame.origin.x = frame.size.width
                   fromView.frame = frame
               }) { (success) in
                   transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                   fromView.removeFromSuperview()
               }
           })
       }
       
       func animatePushTransition(using transitionContext: UIViewControllerContextTransitioning) {
           let container = transitionContext.containerView
           guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else { return }
           
           var frame = originFrame
           frame.origin.x = frame.size.width
           toView.frame = frame
           toView.alpha = 0
           toView.layoutIfNeeded()
           container.addSubview(toView)
           UIView.animate(withDuration: duration, animations: {
               toView.frame = self.originFrame
               toView.alpha = 1
           }, completion: { (finished) in
               UIView.animate(withDuration: 0.1, animations: {
                   toView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
               }) { (success) in
                   transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
               }
           })
       }
}
