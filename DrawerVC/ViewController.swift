//
//  ViewController.swift
//  DrawerVC
//
//  Created by Manas Mishra on 29/04/18.
//  Copyright © 2018 manas. All rights reserved.
//

import UIKit
let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height

class ViewController: UIViewController, UIViewControllerTransitioningDelegate {
    let interactor = Interactor()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    deinit {
        print("1")
    }


    @IBAction func presentVC(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ToBePresentedViewController") as? ToBePresentedViewController
        vc?.transitioningDelegate = self
        vc?.interactor = interactor
        self.present(vc!, animated: true, completion: nil)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DashboardTransitionAnimator(presenting: false, duration: 1)
    }
//    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return DashboardTransitionAnimator(presenting: true, duration: 1)
//    }
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if interactor.hasStarted {
            return interactor
        }
        return nil
    }
    
    @IBAction func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        
        let percentThreshold: CGFloat = 0.3
        // convert y-position to downward pull progress (percentage)
        let translation = sender.translation(in: view)
        
        if sender.state == .began {
            if (translation.x > (screenWidth - 220)) && (translation.x > (screenHeight - 220)) {
                
            } else {
                return
            }
        }
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ToBePresentedViewController") as! ToBePresentedViewController
        vc.transitioningDelegate = self
        vc.interactor = interactor
        switch sender.state {
        case .began:
            interactor.hasStarted = true
            present(vc, animated: true, completion: nil)
            //dismiss(animated: true, completion: nil)
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finish()
                : interactor.cancel()
        default:
            break
        }
    }
    
}

