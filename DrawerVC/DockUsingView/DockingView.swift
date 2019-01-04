//
//  DockingView.swift
//  DrawerVC
//
//  Created by Manas Mishra on 28/11/18.
//  Copyright © 2018 manas. All rights reserved.
//

import UIKit

enum DockingViewState {
    case expanded
    case docked
    case dismissed
    case transitionUpWard
    case transitionDownWard
}


class DockingView: UIView {
    private struct DeviceSpecific {
        static let height = UIScreen.main.bounds.height
        static let width = UIScreen.main.bounds.width
    }

    @IBOutlet weak var topViewRatioConstarint: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    
    private var containerView: UIView!

    //State of the view
    private var dockingViewState: DockingViewState = .dismissed
    
    //Touch starting point for transition
    private var touchStartingPoint: CGPoint?
 
    deinit {
        print("deinit")
    }
    
    
    //Overidable methods and variables
    var panLength: CGFloat = 250
    
    //dockedStateY = DeviceHeight-Dockedstae height-dockedStateClearanceFromBottm
    var dockedStateClearanceFromBottm: CGFloat = 50
    
    //dockedStateX = DeviceWidth-Dockedstae width-dockedStateClearanceFromTrail
    var dockedStateClearanceFromTrail: CGFloat = 10
    
    //minimumWidth = DeviceWidth/dockedStateWidthWRTDeviceWidth
    var dockedStateWidthWRTDeviceWidth: CGFloat = 2.5
    
    //topViewHeight = Dockingview.height/tvRatio
    var topViewRatio: CGFloat = 16/9 {
        didSet {
            self.topViewRatioConstarint.constant = topViewRatio
        }
    }
    
    //Actual threSholdHeight = thresholdHeightForTransitionWRTScreenHegiht*DeviceHeight
    var thresholdHeightForTransitionWRTScreenHegiht: CGFloat = 0.5
    
    // Called after view is appeared and subclass may override this method
    func viewAppeared(fromState: DockingViewState, toState: DockingViewState) {
        
    }
    // Called before view is going to disappear and subclass may override this method
    func viewGoingToDisAppear(viewState: DockingViewState) {
        
    }
}

// Methods For only this class and non-overidable by sub classes
extension DockingView {
    var dockedStatesize: CGSize {
        let width = DeviceSpecific.width/dockedStateWidthWRTDeviceWidth
        let height = width/topViewRatio
        return CGSize(width: width, height: height)
    }
    
    var thresholdSize: CGSize {
        return CGSize(width: DeviceSpecific.width*thresholdHeightForTransitionWRTScreenHegiht, height: DeviceSpecific.height*thresholdHeightForTransitionWRTScreenHegiht)
    }
    
    class func initialize(_ superview: UIView) -> DockingView? {
        guard let dView = Bundle.main.loadNibNamed("DockingView", owner: self, options: nil)?.first as? DockingView else {return nil}
        dView.frame = CGRect(x: 0, y: DeviceSpecific.height, width: DeviceSpecific.width, height: DeviceSpecific.height)
        dView.addGestureRecognizer()
        dView.addSwipeGestureRecognizer()
        dView.containerView = superview
        dView.containerView.addSubview(dView)
        return dView
    }
    func present(animation: Bool = true) {
        let animationTime = animation ? 0.5 : 0
        let newFrame = self.containerView.frame
        UIView.animate(withDuration: animationTime, animations: {
            self.frame = newFrame
        }) { (_) in
            let previousState = self.dockingViewState
            self.dockingViewState = .expanded
            self.viewAppeared(fromState: previousState, toState: .expanded)
        }
    }
}

// Touch Related methods
extension DockingView {
    enum TouchState {
        case began
        case transition
        case end
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: containerView)
            self.viewIsTouched(touchingPoint: currentPoint, touchState: .began)
            // print("lastPoint=== \(String(describing: lastPoint))")
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: containerView)
            //print("lastPoint=== \(String(describing: currentPoint))")
            
            if let newFrame = self.viewIsTouched(touchingPoint: currentPoint, touchState: .transition) {
                self.frame = newFrame
                containerView.layoutIfNeeded()
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: containerView)
            if let newFrame = self.viewIsTouched(touchingPoint: currentPoint, touchState: .end) {
                UIView.animate(withDuration: 0.3) {
                    self.frame = newFrame
                    self.containerView.layoutIfNeeded()
                }
            }
        }
    }
}


//Touch Transition related Helper functions
extension DockingView {
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
    func gettingFinalFrameForTouchEnd(_ endFrame: CGRect, viewState: DockingViewState, endPoint: CGPoint) -> CGRect {
        var newFrame = endFrame
        var dC = endPoint.y - (touchStartingPoint?.y ?? 0)
        dC = (dC<0) ? -dC: dC
        dC = (dC == 0) ? 1: dC
        if dC < (0.1*panLength) {
            if (viewState == .transitionDownWard) || (viewState == .expanded) {
                newFrame = CGRect(x: 0, y: 0, width: DeviceSpecific.width, height: DeviceSpecific.height)
                self.dockingViewState = .expanded
            } else if viewState == .transitionUpWard || (viewState == .docked) {
                let dockedY = DockingView.DeviceSpecific.height-dockedStatesize.height-dockedStateClearanceFromBottm
                let dockedX = DockingView.DeviceSpecific.width-dockedStatesize.width-dockedStateClearanceFromTrail
                newFrame = CGRect(x: dockedX, y: dockedY, width: dockedStatesize.width, height: dockedStatesize.height)
                self.dockingViewState = .docked
            }
        } else {
            if viewState == .transitionDownWard {
                if endFrame.size.width > thresholdSize.width {
                    newFrame = CGRect(x: 0, y: 0, width: DeviceSpecific.width, height: DeviceSpecific.height)
                    self.dockingViewState = .expanded
                } else {
                    let dockedY = DockingView.DeviceSpecific.height-dockedStatesize.height-dockedStateClearanceFromBottm
                    let dockedX = DockingView.DeviceSpecific.width-dockedStatesize.width-dockedStateClearanceFromTrail
                    newFrame = CGRect(x: dockedX, y: dockedY, width: dockedStatesize.width, height: dockedStatesize.height)
                    self.dockingViewState = .docked
                }
            } else if viewState == .transitionUpWard {
                if endFrame.size.width > thresholdSize.width {
                    newFrame = CGRect(x: 0, y: 0, width: DeviceSpecific.width, height: DeviceSpecific.height)
                    self.dockingViewState = .expanded
                } else {
                    let dockedY = DockingView.DeviceSpecific.height-dockedStatesize.height-dockedStateClearanceFromBottm
                    let dockedX = DockingView.DeviceSpecific.width-dockedStatesize.width-dockedStateClearanceFromTrail
                    newFrame = CGRect(x: dockedX, y: dockedY, width: DeviceSpecific.width, height: DeviceSpecific.height)
                    self.dockingViewState = .docked
                }
            }
        }
        return newFrame
    }
    
    func getFrameOfTheDockingView(touchingPoint: CGPoint, viewState: DockingViewState) -> CGRect {
        var dC = touchingPoint.y - (touchStartingPoint?.y ?? 0)
        dC = (dC>(panLength-1)) ? (panLength-1) : dC
        dC = viewState == .transitionUpWard ? panLength+dC:dC
        var currentHeight = ((DeviceSpecific.height - dockedStatesize.height)*(panLength-dC)/panLength) + dockedStatesize.height
        
        if currentHeight > DeviceSpecific.height {
            currentHeight = DeviceSpecific.height
        } else if currentHeight < dockedStatesize.height {
            currentHeight = dockedStatesize.height
        }
        var currentWidth = ((DeviceSpecific.width - dockedStatesize.width)*(panLength-dC)/panLength) + dockedStatesize.width
        if currentWidth > DeviceSpecific.width {
            currentWidth = DeviceSpecific.width
        } else if currentWidth < dockedStatesize.width {
            currentWidth = dockedStatesize.width
        }
        var currentY = DockingView.DeviceSpecific.height-currentHeight
        if currentY + dockedStatesize.height + dockedStateClearanceFromBottm > DeviceSpecific.height {
            currentY = DeviceSpecific.height - dockedStatesize.height - dockedStateClearanceFromBottm
        }
        
        var currentX = DockingView.DeviceSpecific.width-currentWidth
        if currentX + dockedStatesize.width + dockedStateClearanceFromTrail > DeviceSpecific.width {
            currentX = DeviceSpecific.width - dockedStatesize.width - dockedStateClearanceFromTrail
        }
        
        let newFrame = CGRect(x: currentX, y: currentY, width: currentWidth, height: currentHeight)
        return newFrame
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
                self.containerView.layoutIfNeeded()
            }) { (_) in
                self.dockingViewState = .dismissed
                self.viewGoingToDisAppear(viewState: .dismissed)
                self.containerView.removeFromSuperview()
            }
        }
    }
}
