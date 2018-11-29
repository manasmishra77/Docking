//
//  DockChildViewController.swift
//  DrawerVC
//
//  Created by Manas Mishra on 15/09/18.
//  Copyright © 2018 manas. All rights reserved.
//

import UIKit

class DockChildViewController: UIViewController {
    @IBOutlet var diagonalPanGEsture: UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = .red
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("11")
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("222222")
    }
    deinit {
        "In Child deinit"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func panGestureDetected(_ sender: Any) {
        self.willMove(toParentViewController: nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    
    
}
