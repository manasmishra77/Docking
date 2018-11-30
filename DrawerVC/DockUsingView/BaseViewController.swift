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
        //configureDockingView()
    }
    func configureDockingView() {
        guard let dockingView = dockingView else {return}
        createPanGestureRecognizer(targetView: dockingView)
    }
    
    func createPanGestureRecognizer(targetView: UIView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(panGesture:)))
        targetView.addGestureRecognizer(panGesture)
    }
    @IBAction func dockingViewPresentButtonTapped(_ sender: Any) {
        dockingView = DockingView.initialize(CGRect(x: 0, y: DockingView.DeviceSpecific.height, width: DockingView.DeviceSpecific.width, height: DockingView.DeviceSpecific.height))
        view.addSubview(dockingView!)
        configureDockingView()
        let newFrame = CGRect(x: 0, y: 0, width: DockingView.DeviceSpecific.width, height: DockingView.DeviceSpecific.height)
        UIView.animate(withDuration: 1, animations: {
            self.dockingView?.frame = newFrame
        }, completion: nil)
    }
    
    @objc func handlePanGesture(panGesture: UIPanGestureRecognizer) {
        // get translation
        let translation = panGesture.translation(in: view)
       // print(translation)
        let panX = abs(translation.x)
        let panY = abs(translation.y)
        let widthMultiplier = 1 - panX/DockingView.DeviceSpecific.width
        let heightMultiplier = 1 - panY/DockingView.DeviceSpecific.height
        let newWidthOfDockingView = DockingView.DeviceSpecific.width*widthMultiplier
        let newHeightOfDockingView = DockingView.DeviceSpecific.height*heightMultiplier

        
        if let view = panGesture.view {
            let newFrame = CGRect(x: translation.x, y: translation.y, width: newWidthOfDockingView, height: newHeightOfDockingView)
            view.frame = newFrame
        }
       
        
        
        
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
