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
    }

    @IBOutlet weak var topViewRatioConstarint: NSLayoutConstraint!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var topView: UIView!
    var dockedStateWidthWRTDeviceWidth: CGFloat!
    var dockingViewState: DockingViewState = .dismissed
    var tvRatio: CGFloat!
    var thresholdHeightForTransitionWRTScreenHegiht: CGFloat!
    var isDownward: Bool = true
    
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
    
    var thresholdSize: CGSize {
        return CGSize(width: DeviceSpecific.width*thresholdHeightForTransitionWRTScreenHegiht, height: DeviceSpecific.height*thresholdHeightForTransitionWRTScreenHegiht)
    }
    
    func sizeOfDockingView(panX: CGFloat, panY: CGFloat) -> CGSize {
        //Panx Parameter is not used here. New width is according to height
        let newPanX = DeviceSpecific.width*(panY/DeviceSpecific.height)
        switch dockingViewState {
        case .expanded:
            return CGSize(width: DeviceSpecific.width, height: DeviceSpecific.height)
        case .docked:
            let newWidth = DeviceSpecific.width/dockedStateWidthWRTDeviceWidth
            let newHeight = newWidth*(1/tvRatio)
            return CGSize(width: newWidth, height: newHeight)
        case .dismissed:
            break
        case .transition:
            let widthMultiplier = 1 - newPanX/DockingView.DeviceSpecific.width
            let heightMultiplier = 1 - panY/DockingView.DeviceSpecific.height
            var newWidthOfDockingView = DockingView.DeviceSpecific.width*widthMultiplier
            let newHeightOfDockingView = DockingView.DeviceSpecific.height*heightMultiplier
            let fixMinimumWidth = DeviceSpecific.width/dockedStateWidthWRTDeviceWidth
            newWidthOfDockingView = (newWidthOfDockingView<fixMinimumWidth) ? fixMinimumWidth : newWidthOfDockingView
            return CGSize(width: newWidthOfDockingView, height: newHeightOfDockingView)
            
        }
        return CGSize.zero
    }
    
    func frameOfDockingView(translation: CGPoint) -> CGRect {
        
        let isDownward = translation.y > 0
       // print("Downward: ----- \(isDownward) ----- \(translation.y)")
        
        var panX = translation.x
        var panY = translation.y
        if !isDownward {
            panX = DockingView.DeviceSpecific.width + panX
            panY = DockingView.DeviceSpecific.height + panY
        } else {
            panX = abs(translation.x < 0 ? 0 : translation.x)
            panY = abs(translation.y < 0 ? 0 : translation.y)
        }
       
        switch dockingViewState {
        case .expanded:
            let newSize = self.sizeOfDockingView(panX: panX, panY: panY)
            let newFrame = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
            return newFrame
        case .docked:
            let newSize = self.sizeOfDockingView(panX: panX, panY: panY)
            let dockX = DeviceSpecific.width - newSize.width - 10
            let dockY = DeviceSpecific.height - newSize.height - 10
            let newFrame = CGRect(x: dockX, y: dockY, width: newSize.width, height: newSize.height)
            return newFrame
        case .dismissed:
            break
        case .transition:
            var newSize = self.sizeOfDockingView(panX: panX, panY: panY)
            if !isDownward {
                newSize = self.sizeForUpwardMotion(transX: translation.x, transY: translation.y)
            } else {
            }
            let newX = DeviceSpecific.width-newSize.width
            let newY = DeviceSpecific.height-newSize.height
            let newFrame = CGRect(x: newX, y: newY, width: newSize.width, height: newSize.height)
           // print("new size: -- \(newSize)")
            return newFrame
        }
        return CGRect.zero
    }
    
    func sizeForUpwardMotion(transX: CGFloat, transY: CGFloat) -> CGSize {
        //Panx Parameter is not used here. New width is according to height
        let panY = transY <= 0 ? -transY: transY
        print("transX -- \(transX) --- transY -- \(transY)")
        let newPanX = DeviceSpecific.width*(panY/DeviceSpecific.height)
        switch dockingViewState {
        case .expanded:
            return CGSize(width: DeviceSpecific.width, height: DeviceSpecific.height)
        case .docked:
            let newWidth = DeviceSpecific.width/dockedStateWidthWRTDeviceWidth
            let newHeight = newWidth*(1/tvRatio)
            return CGSize(width: newWidth, height: newHeight)
        case .dismissed:
            break
        case .transition:
            let widthMultiplier = newPanX/DockingView.DeviceSpecific.width
            let heightMultiplier = panY/DockingView.DeviceSpecific.height
            var newWidthOfDockingView = DockingView.DeviceSpecific.width*widthMultiplier
            let newHeightOfDockingView = DockingView.DeviceSpecific.height*heightMultiplier
            let fixMinimumWidth = DeviceSpecific.width/dockedStateWidthWRTDeviceWidth
            newWidthOfDockingView = (newWidthOfDockingView<fixMinimumWidth) ? fixMinimumWidth : newWidthOfDockingView
            return CGSize(width: newWidthOfDockingView, height: newHeightOfDockingView)
            
        }
        return CGSize.zero
    }
    

    
}

enum DockingViewState {
    case expanded
    case docked
    case dismissed
    case transition
}
