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
    }
   
    @IBAction func dockingViewPresentButtonTapped(_ sender: Any) {
        let container = UIView()
        container.frame = self.view.bounds
        self.view.addSubview(container)
        dockingView = DockingView.initialize(container, referenceView: self.view, type: DockingView.self)
        dockingView?.layoutIfNeeded()
        dockingView?.present()
    }
        
}

class CustomDockingView: DockingView {
    override func dockingViewRatioChangeInTransition(_ scale: CGFloat) {
        
    }
}
