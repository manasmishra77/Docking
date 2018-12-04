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
        guard let dView = panGesture.view as? DockingView else {return}
        // get translation
        let translation = panGesture.translation(in: view)
        print(translation)
        let panX = abs(translation.x)
        let panY = abs(translation.y)
        
        switch panGesture.state {
        case .began:
            // add something you want to happen when the Label Panning has started
            print("In possible case")
        case .changed:
            // add something you want to happen when the Label Panning has been change ( during the moving/panning )
            print("In changed case")
            dView.dockingViewState = .transition
            dView.frame = dView.frameOfDockingView(translation: translation)
        case .ended:
            // add something you want to happen when the Label Panning has ended
            print("In ended case")
            let newSize = dView.sizeOfDockingView(panX: panX, panY: panY)
            if ((newSize.width < dView.thresholdSize.width) && ((newSize.height < dView.thresholdSize.height))) {
                dView.dockingViewState = .docked
            } else {
                dView.dockingViewState = .expanded
            }
            UIView.animate(withDuration: 0.3) {
                dView.frame = dView.frameOfDockingView(translation: translation)
            }
        default:
            print("In default case")
        }
    }

}
