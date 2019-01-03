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
        dockingView = DockingView.initialize(self.view)
        dockingView?.present()
    }
        
}
