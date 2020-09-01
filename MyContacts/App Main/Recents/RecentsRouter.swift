//
//  RecentsRouter.swift
//  MyContacts
//
//  Created by Apoorv Suri on 01/09/20.
//  Copyright © 2020 Apoorv Suri. All rights reserved.
//

import UIKit


protocol RecentsRoutingLogic {
    
}

protocol RecentsDataPassing {
    var dataStore: RecentsDataStore? {get set}
}

class RecentsRouter: RecentsRoutingLogic, RecentsDataPassing {
    var dataStore: RecentsDataStore?
    
    weak var viewController: UIViewController?
}
