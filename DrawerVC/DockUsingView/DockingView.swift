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
    var tvRatio: CGFloat!
    
    //Actual threSholdHeight = thresholdHeightForTransitionWRTScreenHegiht*DeviceHeight
    var thresholdHeightForTransitionWRTScreenHegiht: CGFloat!
    
    var dockedStatesize: CGSize {
        let width = DeviceSpecific.width/dockedStateWidthWRTDeviceWidth
        let height = width/tvRatio
        return CGSize(width: width, height: height)
    }
    
    var thresholdSize: CGSize {
        return CGSize(width: DeviceSpecific.width*thresholdHeightForTransitionWRTScreenHegiht, height: DeviceSpecific.height*thresholdHeightForTransitionWRTScreenHegiht)
    }

    
    class func initialize(_ frame: CGRect, topViewPropertion tVRatio: CGFloat = 16/9, dockedStateRatio: CGFloat = 2.5, thresholdHeight: CGFloat = 0.5) -> DockingView {
        let dView = Bundle.main.loadNibNamed("DockingView", owner: self, options: nil)?.first as! DockingView
        dView.frame = frame
        dView.dockedStateWidthWRTDeviceWidth = dockedStateRatio
        dView.topViewRatioConstarint.constant = tVRatio
        dView.tvRatio = tVRatio
        dView.thresholdHeightForTransitionWRTScreenHegiht = 0.5
        return dView
    }
    
    deinit {
        print("deinit")
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
                let dockedY = DockingView.DeviceSpecific.height-dockedStatesize.height
                let dockedX = DockingView.DeviceSpecific.width-dockedStatesize.width
                newFrame = CGRect(x: dockedX, y: dockedY, width: dockedStatesize.width, height: dockedStatesize.height)
                self.dockingViewState = .docked
            }
        } else {
            if viewState == .transitionDownWard {
                if endFrame.size.width > thresholdSize.width {
                    newFrame = CGRect(x: 0, y: 0, width: DeviceSpecific.width, height: DeviceSpecific.height)
                    self.dockingViewState = .expanded
                } else {
                    let dockedY = DockingView.DeviceSpecific.height-dockedStatesize.height
                    let dockedX = DockingView.DeviceSpecific.width-dockedStatesize.width
                    newFrame = CGRect(x: dockedX, y: dockedY, width: dockedStatesize.width, height: dockedStatesize.height)
                    self.dockingViewState = .docked
                }
            } else if viewState == .transitionUpWard {
                if endFrame.size.width > thresholdSize.width {
                    newFrame = CGRect(x: 0, y: 0, width: DeviceSpecific.width, height: DeviceSpecific.height)
                    self.dockingViewState = .expanded
                } else {
                    let dockedY = DockingView.DeviceSpecific.height-thresholdSize.height
                    let dockedX = DockingView.DeviceSpecific.width-thresholdSize.width
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
        let currentY = DockingView.DeviceSpecific.height-currentHeight
        let currentX = DockingView.DeviceSpecific.width-currentWidth
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
