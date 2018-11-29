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

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var topView: UIView!
    var dockingViewState: DockingViewState = .dismissed
    
    class func initialize(_ frame: CGRect) -> DockingView {
        let dView = Bundle.main.loadNibNamed("DockingView", owner: self, options: nil)?.first as! DockingView
        dView.frame = frame
        return dView
    }
    
}

enum DockingViewState {
    case expanded
    case docked
    case dismissed
    case transition
}
