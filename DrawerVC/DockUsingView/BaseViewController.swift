//
//  BaseViewController.swift
//  DrawerVC
//
//  Created by Manas Mishra on 28/11/18.
//  Copyright © 2018 manas. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    var dockingView: DockingView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //configureDockingView()
    }
    func configureDockingView() {
        //guard let dockingView = dockingView else {return}
        //createPanGestureRecognizer(targetView: self.view)
    }
    
    func createPanGestureRecognizer(targetView: UIView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(panGesture:)))
        targetView.addGestureRecognizer(panGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture(tapGesture:)))
        targetView.addGestureRecognizer(tapGesture)
    }
    @IBAction func dockingViewPresentButtonTapped(_ sender: Any) {
        dockingView = DockingView.initialize(CGRect(x: 0, y: DockingView.DeviceSpecific.height, width: DockingView.DeviceSpecific.width, height: DockingView.DeviceSpecific.height))
        view.addSubview(dockingView!)
        //configureDockingView()
        let newFrame = CGRect(x: 0, y: 0, width: DockingView.DeviceSpecific.width, height: DockingView.DeviceSpecific.height)
        UIView.animate(withDuration: 1, animations: {
            self.dockingView?.frame = newFrame
        }, completion: nil)
    }
    
    var initialPoint: CGPoint?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: self.view)
            dockingView?.viewIsTouched(touchingPoint: currentPoint, touchState: .began)
           // print("lastPoint=== \(String(describing: lastPoint))")
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: self.view)
             print("lastPoint=== \(String(describing: currentPoint))")

            if let newFrame = dockingView?.viewIsTouched(touchingPoint: currentPoint, touchState: .transition) {
                dockingView?.frame = newFrame
                self.view.layoutIfNeeded()
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: self.view)
            if let newFrame = dockingView?.viewIsTouched(touchingPoint: currentPoint, touchState: .end) {
                UIView.animate(withDuration: 0.3) {
                    self.dockingView?.frame = newFrame
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    @objc func handlePanGesture(panGesture: UIPanGestureRecognizer) {
        // Handling the case when docking view is in docked state and right swipped
        
        //guard !dismissDockingView(panGesture: panGesture) else {return}
        
        
        //guard let dView = panGesture.view as? DockingView else {return}
        // get translation
        //let translation = panGesture.translation(in: self.view)
        //print(translation)
        //print(panGesture.velocity(in: view))
        return
//        var panX = abs(translation.x)
//        let panY = abs(translation.y)
//
//        switch panGesture.state {
//        case .began:
//            // add something you want to happen when the Label Panning has started
//            print("In possible case")
//            if translation.y <= 0 {
//                dView.isDownward = false
//                return
//            }
//        case .changed:
//            // add something you want to happen when the Label Panning has been change ( during the moving/panning )
//            print("In changed case")
//            dView.dockingViewState = .transition
//            dView.frame = dView.frameOfDockingView(translation: translation)
//        case .ended:
//            // add something you want to happen when the Label Panning has ended
//            print("In ended case")
//            var newSize = dView.sizeOfDockingView(panX: panX, panY: panY)
//            if !dView.isDownward {
//                newSize = dView.sizeForUpwardMotion(transX: translation.x, transY: translation.y)
//            }
//
//            if ((newSize.width < dView.thresholdSize.width) && ((newSize.height < dView.thresholdSize.height))) {
//                dView.dockingViewState = .docked
//            } else {
//                dView.dockingViewState = .expanded
//            }
//            let newFrame = dView.frameOfDockingView(translation: translation)
//            UIView.animate(withDuration: 0.3) {
//                dView.frame = newFrame
//                self.view.layoutIfNeeded()
//            }
//            if !dView.isDownward {
//                dView.isDownward = true
//            }
//        default:
//            print("In default case")
//        }
    }
    @objc func handleTapGesture(tapGesture: UITapGestureRecognizer)  {
        //HandleTap
        guard let dView = tapGesture.view as? DockingView else {return}
        if dView.dockingViewState == .docked {
            let newFrame = CGRect(x: 0, y: 0, width: DockingView.DeviceSpecific.width, height: DockingView.DeviceSpecific.height)
            UIView.animate(withDuration: 0.5) {
                dView.frame = newFrame
                self.view.layoutIfNeeded()
            }
            UIView.animate(withDuration: 0.5, animations: {
                dView.frame = newFrame
                self.view.layoutIfNeeded()
            }) { (_) in
                dView.dockingViewState = .expanded
            }
        }
    }
    
    func dismissDockingView(panGesture: UIPanGestureRecognizer) -> Bool {
        return false
        guard let dView = panGesture.view as? DockingView else {return false}
        guard dView.dockingViewState == .docked else {
            return false
        }
        let velocity = panGesture.velocity(in: self.view)
        guard velocity.x < 0, velocity.y <= 0 else {
            return false
        }
        var newFrame = dView.frame
        newFrame.origin.x = 0
        UIView.animate(withDuration: 0.5, animations: {
            dView.frame = newFrame
            dView.alpha = 0
            self.view.layoutIfNeeded()
        }) { (_) in
            dView.dockingViewState = .dismissed
            self.dockingView?.removeFromSuperview()
            self.dockingView = nil
        }
        return true
    }
}
