//
//  UIWindow.swift
//  MyContacts
//
//  Created by Apoorv Suri on 30/08/20.
//  Copyright © 2020 Apoorv Suri. All rights reserved.
//

import UIKit


//---------------------------------------------------------------------
// MARK: GET THE TOPMOST CONTROLLER
//---------------------------------------------------------------------

public extension UIWindow {
    
    var visibleViewController: UIViewController? {
        
        return UIWindow.getVisibleViewControllerFrom(vc: self.rootViewController)
    }
    
    static func getVisibleViewControllerFrom(vc: UIViewController?) -> UIViewController? {
        
        if let nc = vc as? UINavigationController {
            
            return UIWindow.getVisibleViewControllerFrom(vc: nc.visibleViewController)
            
        } else if let tc = vc as? UITabBarController {
            
            return UIWindow.getVisibleViewControllerFrom(vc: tc.selectedViewController)
            
        } else if let sc = vc as? UISearchController {
            
            return sc.presentingViewController

        } else {
            
            if let pvc = vc?.presentedViewController {
                
                return UIWindow.getVisibleViewControllerFrom(vc: pvc)
                
            } else {
                
                return vc
            }
        }
    }
}
