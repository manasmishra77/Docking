//
//  DockBaseViewController.swift
//  DrawerVC
//
//  Created by Manas Mishra on 15/09/18.
//  Copyright © 2018 manas. All rights reserved.
//

import UIKit

class DockBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didClickOnPresentDuckChild(_ sender: Any) {
        let vc = DockChildViewController(nibName: nil, bundle: nil)
        addChildViewController(vc)
        view.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
    }
    

}
