//
//  DashboardTransitionAnimator.swift
//  DrawerVC
//
//  Created by Manas Mishra on 29/04/18.
//  Copyright © 2018 manas. All rights reserved.
//

import UIKit

class DashboardTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var presenting = false
    var duration = 4.0
    
    //MARK: Initializers
    convenience init(presenting: Bool, duration: Double = 4) {
        self.init()
        self.presenting = presenting
        self.duration = duration
    }
    
    //MARK: Configuration
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    //MARK: Transition from left to right (Sidebar)
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else {
                return
        }
        
        
        if presenting {
            
            
        } else {
            transitionContext.containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
            let screenBounds = UIScreen.main.bounds
            let finalSize = CGSize(width: 200, height: 200)
            let bottomLeftCorner = CGPoint(x: 200, y: screenBounds.height - 100)
            let finalFrame = CGRect(origin: bottomLeftCorner, size: finalSize)
            
            UIView.animate(
                withDuration: transitionDuration(using: transitionContext),
                animations: {
                    fromVC.view.frame = finalFrame
            },
                completion: { _ in
                   // transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            )
        }
        
        
     
    }
}
















