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
    
    var thresholdSize: CGSize {
        return CGSize(width: DeviceSpecific.width/thresholdHeightForTransitionWRTScreenHegiht, height: DeviceSpecific.height/thresholdHeightForTransitionWRTScreenHegiht)
    }
    
    func sizeOfDockingView(panX: CGFloat, panY: CGFloat) -> CGSize {
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
            let widthMultiplier = 1 - panX/DockingView.DeviceSpecific.width
            let heightMultiplier = 1 - panY/DockingView.DeviceSpecific.height
            let newWidthOfDockingView = DockingView.DeviceSpecific.width*widthMultiplier
            let newHeightOfDockingView = DockingView.DeviceSpecific.height*heightMultiplier
            return CGSize(width: newWidthOfDockingView, height: newHeightOfDockingView)
            
        }
        return CGSize.zero
    }
    
    func <#name#>(<#parameters#>) -> <#return type#> {
        <#function body#>
    }
    
    class func initialize(_ frame: CGRect, topViewPropertion tVRatio: CGFloat = 16/9, dockedStateRatio: CGFloat = 2.5, thresholdHeight: CGFloat = 0.5) -> DockingView {
        let dView = Bundle.main.loadNibNamed("DockingView", owner: self, options: nil)?.first as! DockingView
        dView.frame = frame
        dView.dockedStateWidthWRTDeviceWidth = dockedStateRatio
        dView.topViewRatioConstarint.constant = tVRatio
        dView.thresholdHeightForTransitionWRTScreenHegiht = 0.5
        return dView
    }
    
}

enum DockingViewState {
    case expanded
    case docked
    case dismissed
    case transition
}
