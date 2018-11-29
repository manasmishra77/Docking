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
    func configureDockingView() {
        createPanGestureRecognizer(targetView: self.view)
    }
    
    func createPanGestureRecognizer(targetView: UIView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(panGesture:)))
        targetView.addGestureRecognizer(panGesture)
    }
    
    @objc func handlePanGesture(panGesture: UIPanGestureRecognizer) {
        // get translation
        let translation = panGesture.translation(in: view)
        
        
        switch panGesture.state {
        case .began:
            // add something you want to happen when the Label Panning has started
            print("In possible case")
        case .changed:
            // add something you want to happen when the Label Panning has been change ( during the moving/panning )
            print("In changed case")
        case .ended:
            // add something you want to happen when the Label Panning has ended
            print("In ended case")
        default:
            print("In default case")
        }
    }

}
