//
//  TransparentBackgrounfModalPresenter.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 7/16/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import Foundation
import UIKit

class SuccessModalPresenter: NSObject, UIViewControllerAnimatedTransitioning {
    
    var duration: TimeInterval
       var isPush: Bool
       var originFrame: CGRect
       
       init(isPush: Bool, duration: TimeInterval = 0.5, originFrame: CGRect = .zero) {
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

private extension SuccessModalPresenter {
    func animatePopTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) else { return }
        
        UIView.animate(withDuration: duration, animations: {
            fromView.alpha = 0
        }, completion: { (finished) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            fromView.removeFromSuperview()
        })
    }
    
    func animatePushTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else { return }
        
        toView.frame = originFrame
        toView.alpha = 0
        toView.layoutIfNeeded()
        container.addSubview(toView)
        UIView.animate(withDuration: duration, animations: {
            toView.alpha = 1
        }, completion: { (finished) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    

}
