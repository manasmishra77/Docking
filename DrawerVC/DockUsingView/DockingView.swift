//
//  DockingView.swift
//  DrawerVC
//
//  Created by Manas Mishra on 28/11/18.
//  Copyright © 2018 manas. All rights reserved.
//

import UIKit

class DockingView: UIView {
    struct DeviceSpecific {
        static let height = UIScreen.main.bounds.height
        static let width = UIScreen.main.bounds.width
        static let panLength: CGFloat = 250
        static let dockedStateClearanceFromBottm: CGFloat = 50 //dockedStateY = DeviceHeight-Dockedstae height-dockedStateClearanceFromBottm
        static let dockedStateClearanceFromTrail: CGFloat = 10 //dockedStateX = DeviceWidth-Dockedstae width-dockedStateClearanceFromTrail
    }

    @IBOutlet weak var topViewRatioConstarint: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    
    //minimumWidth = DeviceWidth/dockedStateWidthWRTDeviceWidth
    var dockedStateWidthWRTDeviceWidth: CGFloat!
    
    //State of the view
    var dockingViewState: DockingViewState = .expanded
    
    //topViewHeight = Dockingview.height/tvRatio
    var topViewRatio: CGFloat!
    
    //Actual threSholdHeight = thresholdHeightForTransitionWRTScreenHegiht*DeviceHeight
    var thresholdHeightForTransitionWRTScreenHegiht: CGFloat!
    
    var dockedStatesize: CGSize {
        let width = DeviceSpecific.width/dockedStateWidthWRTDeviceWidth
        let height = width/topViewRatio
        return CGSize(width: width, height: height)
    }
    
    var thresholdSize: CGSize {
        return CGSize(width: DeviceSpecific.width*thresholdHeightForTransitionWRTScreenHegiht, height: DeviceSpecific.height*thresholdHeightForTransitionWRTScreenHegiht)
    }

    
    class func initialize(_ superview: UIView, topViewPropertion tVRatio: CGFloat = 16/9, dockedStateRatio: CGFloat = 2.5, thresholdHeight: CGFloat = 0.5) -> DockingView {
        let dView = Bundle.main.loadNibNamed("DockingView", owner: self, options: nil)?.first as! DockingView
        dView.frame = CGRect(x: 0, y: DeviceSpecific.height, width: DockingView.DeviceSpecific.width, height: DeviceSpecific.height)
        dView.dockedStateWidthWRTDeviceWidth = dockedStateRatio
        dView.topViewRatioConstarint.constant = tVRatio
        dView.topViewRatio = tVRatio
        dView.thresholdHeightForTransitionWRTScreenHegiht = 0.5
        dView.addGestureRecognizer()
        dView.addSwipeGestureRecognizer()
        superview.addSubview(dView)
        return dView
    }
    
    deinit {
        print("deinit")
    }
    
    func present(animation: Bool = true) {
        let animationTime = animation ? 0.5 : 0
        guard let newFrame = self.superview?.frame else {return}
        UIView.animate(withDuration: animationTime, animations: {
            self.frame = newFrame
        }, completion: nil)
    }
    
    var touchStartingPoint: CGPoint?
    
    func viewIsTouched(touchingPoint: CGPoint, touchState: TouchState) -> CGRect? {
        if touchState == .began {
            touchStartingPoint = nil
            if self.dockingViewState == .expanded {
                if touchingPoint.y < (topView.frame.origin.y + topView.frame.height) {
                    touchStartingPoint = touchingPoint
                }
            } else if self.dockingViewState == .docked {
                let isValidY: Bool = touchingPoint.y > (DeviceSpecific.height-dockedStatesize.height)
                let isValidX: Bool = touchingPoint.x > (DeviceSpecific.width-dockedStatesize.width)
                if isValidX, isValidY {
                    touchStartingPoint = touchingPoint
                }
            }
            
        } else if touchState == .transition {
            guard touchStartingPoint != nil else {return nil}
            switch dockingViewState {
            case .transitionDownWard, .transitionUpWard:
                return getFrameOfTheDockingView(touchingPoint: touchingPoint, viewState: dockingViewState)
            default:
                if ((touchStartingPoint?.y ?? 0) > touchingPoint.y) {
                    dockingViewState = .transitionUpWard
                } else if ((touchStartingPoint?.y ?? 0) < touchingPoint.y) {
                    dockingViewState = .transitionDownWard
                }
            }
        } else if touchState == .end {
            guard touchStartingPoint != nil else {return nil}
            let endFrame = getFrameOfTheDockingView(touchingPoint: touchingPoint, viewState: self.dockingViewState)
            let newFrame =  gettingFinalFrameForTouchEnd(endFrame, viewState: self.dockingViewState, endPoint: touchingPoint)
            touchStartingPoint = nil
            return newFrame
        }
        return nil
    }
}

//Helper functions
extension DockingView {
    func gettingFinalFrameForTouchEnd(_ endFrame: CGRect, viewState: DockingViewState, endPoint: CGPoint) -> CGRect {
        var newFrame = endFrame
        var dC = endPoint.y - (touchStartingPoint?.y ?? 0)
        dC = (dC<0) ? -dC: dC
        dC = (dC == 0) ? 1: dC
        if dC < (0.1*DeviceSpecific.panLength) {
            if (viewState == .transitionDownWard) || (viewState == .expanded) {
                newFrame = CGRect(x: 0, y: 0, width: DeviceSpecific.width, height: DeviceSpecific.height)
                self.dockingViewState = .expanded
            } else if viewState == .transitionUpWard || (viewState == .docked) {
                let dockedY = DockingView.DeviceSpecific.height-dockedStatesize.height-DeviceSpecific.dockedStateClearanceFromBottm
                let dockedX = DockingView.DeviceSpecific.width-dockedStatesize.width-DeviceSpecific.dockedStateClearanceFromTrail
                newFrame = CGRect(x: dockedX, y: dockedY, width: dockedStatesize.width, height: dockedStatesize.height)
                self.dockingViewState = .docked
            }
        } else {
            if viewState == .transitionDownWard {
                if endFrame.size.width > thresholdSize.width {
                    newFrame = CGRect(x: 0, y: 0, width: DeviceSpecific.width, height: DeviceSpecific.height)
                    self.dockingViewState = .expanded
                } else {
                    let dockedY = DockingView.DeviceSpecific.height-dockedStatesize.height-DeviceSpecific.dockedStateClearanceFromBottm
                    let dockedX = DockingView.DeviceSpecific.width-dockedStatesize.width-DeviceSpecific.dockedStateClearanceFromTrail
                    newFrame = CGRect(x: dockedX, y: dockedY, width: dockedStatesize.width, height: dockedStatesize.height)
                    self.dockingViewState = .docked
                }
            } else if viewState == .transitionUpWard {
                if endFrame.size.width > thresholdSize.width {
                    newFrame = CGRect(x: 0, y: 0, width: DeviceSpecific.width, height: DeviceSpecific.height)
                    self.dockingViewState = .expanded
                } else {
                    let dockedY = DockingView.DeviceSpecific.height-dockedStatesize.height-DeviceSpecific.dockedStateClearanceFromBottm
                    let dockedX = DockingView.DeviceSpecific.width-dockedStatesize.width-DeviceSpecific.dockedStateClearanceFromTrail
                    newFrame = CGRect(x: dockedX, y: dockedY, width: DeviceSpecific.width, height: DeviceSpecific.height)
                    self.dockingViewState = .docked
                }
            }
        }
        return newFrame
    }
    
    func getFrameOfTheDockingView(touchingPoint: CGPoint, viewState: DockingViewState) -> CGRect {
        var dC = touchingPoint.y - (touchStartingPoint?.y ?? 0)
        dC = (dC>(DeviceSpecific.panLength-1)) ? (DeviceSpecific.panLength-1) : dC
        dC = viewState == .transitionUpWard ? DeviceSpecific.panLength+dC:dC
        var currentHeight = ((DeviceSpecific.height - dockedStatesize.height)*(DeviceSpecific.panLength-dC)/DeviceSpecific.panLength) + dockedStatesize.height
        
        if currentHeight > DeviceSpecific.height {
            currentHeight = DeviceSpecific.height
        } else if currentHeight < dockedStatesize.height {
            currentHeight = dockedStatesize.height
        }
        var currentWidth = ((DeviceSpecific.width - dockedStatesize.width)*(DeviceSpecific.panLength-dC)/DeviceSpecific.panLength) + dockedStatesize.width
        if currentWidth > DeviceSpecific.width {
            currentWidth = DeviceSpecific.width
        } else if currentWidth < dockedStatesize.width {
            currentWidth = dockedStatesize.width
        }
        var currentY = DockingView.DeviceSpecific.height-currentHeight
        if currentY + dockedStatesize.height + DeviceSpecific.dockedStateClearanceFromBottm > DeviceSpecific.height {
            currentY = DeviceSpecific.height - dockedStatesize.height - DeviceSpecific.dockedStateClearanceFromBottm
        }
        
        var currentX = DockingView.DeviceSpecific.width-currentWidth
        if currentX + dockedStatesize.width + DeviceSpecific.dockedStateClearanceFromTrail > DeviceSpecific.width {
            currentX = DeviceSpecific.width - dockedStatesize.width - DeviceSpecific.dockedStateClearanceFromTrail
        }
        
        let newFrame = CGRect(x: currentX, y: currentY, width: currentWidth, height: currentHeight)
        return newFrame
    }
}


enum DockingViewState {
    case expanded
    case docked
    case dismissed
    case transitionUpWard
    case transitionDownWard
}

enum TouchState {
    case began
    case transition
    case end
}


// Touch Related methods
extension DockingView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let superview = self.superview else {return}
        if let touch = touches.first {
            let currentPoint = touch.location(in: superview)
            self.viewIsTouched(touchingPoint: currentPoint, touchState: .began)
            // print("lastPoint=== \(String(describing: lastPoint))")
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let superview = self.superview else {return}
        if let touch = touches.first {
            let currentPoint = touch.location(in: superview)
            //print("lastPoint=== \(String(describing: currentPoint))")
            
            if let newFrame = self.viewIsTouched(touchingPoint: currentPoint, touchState: .transition) {
                self.frame = newFrame
                superview.layoutIfNeeded()
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let superview = self.superview else {return}
        if let touch = touches.first {
            let currentPoint = touch.location(in: superview)
            if let newFrame = self.viewIsTouched(touchingPoint: currentPoint, touchState: .end) {
                UIView.animate(withDuration: 0.3) {
                    self.frame = newFrame
                    superview.layoutIfNeeded()
                }
            }
        }
    }
}

//Tap Gesture related methods
extension DockingView {
    func addGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture(tapGesture:)))
        self.addGestureRecognizer(tapGesture)
    }
    @objc func handleTapGesture(tapGesture: UITapGestureRecognizer)  {
        //HandleTap
        guard (tapGesture.view as? DockingView) != nil else {return}
        if dockingViewState == .docked {
            present()
            dockingViewState = .expanded
        }
    }
}

//Swipe Gesture related methods
extension DockingView {
    func addSwipeGestureRecognizer() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeGesture(swipeGesture:)))
        swipeGesture.direction = .left
        self.addGestureRecognizer(swipeGesture)
    }
    @objc func handleSwipeGesture(swipeGesture: UISwipeGestureRecognizer)  {
        //HandleTap
        guard (swipeGesture.view as? DockingView) != nil else {return}
        if dockingViewState == .docked, swipeGesture.direction == .left {
            var newFrame = self.frame
            newFrame.origin.x = 0
            UIView.animate(withDuration: 0.5, animations: {
                self.frame = newFrame
                self.alpha = 0
                self.superview?.layoutIfNeeded()
            }) { (_) in
                self.dockingViewState = .dismissed
                self.superview?.removeFromSuperview()
            }
        }
    }
}
