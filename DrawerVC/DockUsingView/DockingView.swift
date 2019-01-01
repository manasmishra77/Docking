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
    }

    @IBOutlet weak var topViewRatioConstarint: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    
    //minimumWidth = dockedStateWidthWRTDeviceWidth*DeviceWidth
    var dockedStateWidthWRTDeviceWidth: CGFloat!
    
    //State of the view
    var dockingViewState: DockingViewState = .dismissed
    
    //topViewHeight = tvRatio*Dockingview.height
    var tvRatio: CGFloat!
    
    //Actual threSholdHeight = thresholdHeightForTransitionWRTScreenHegiht*DeviceHeight
    var thresholdHeightForTransitionWRTScreenHegiht: CGFloat!
    
    var dockedStatesize: CGSize {
        let width = DeviceSpecific.width*dockedStateWidthWRTDeviceWidth
        let height = width*tvRatio
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
            touchStartingPoint = touchingPoint
        } else if touchState == .transition {
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
            let endFrame = getFrameOfTheDockingView(touchingPoint: touchingPoint, viewState: self.dockingViewState)
            touchStartingPoint = nil
            if endFrame.size.height == dockedStatesize.height {
                dockingViewState = .docked
            } else {
                dockingViewState = .expanded
            }
            return endFrame
        }
        return nil
    }
}

//Helper functions
extension DockingView {
    func getFrameOfTheDockingView(touchingPoint: CGPoint, viewState: DockingViewState) -> CGRect {
        var dC = touchingPoint.y - (touchStartingPoint?.y ?? 0)
        dC = (dC>(DeviceSpecific.panLength-1)) ? (DeviceSpecific.panLength-1) : dC
        var currentHeight = ((DeviceSpecific.height - dockedStatesize.height)*(DeviceSpecific.panLength-dC)/DeviceSpecific.panLength) + dockedStatesize.height
        if currentHeight > DeviceSpecific.height {
            currentHeight = DeviceSpecific.height
        } else if currentHeight < dockedStatesize.height {
            currentHeight = dockedStatesize.height
        }
        var currentWidth = ((DeviceSpecific.height - dockedStatesize.width)*(DeviceSpecific.panLength-dC)/DeviceSpecific.panLength) + dockedStatesize.width
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
