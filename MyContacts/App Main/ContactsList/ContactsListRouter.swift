//
//  ContactsListRouter.swift
//  MyContacts
//
//  Created by Apoorv Suri on 30/08/20.
//  Copyright © 2020 Apoorv Suri. All rights reserved.
//

import UIKit

protocol ContactListRoutingLogic {
    
}

protocol ContactListDataPassing {
    var dataStore: ContactListDataStore? {get set}
}

class ContactsListRouter: ContactListRoutingLogic, ContactListDataPassing {
    var dataStore: ContactListDataStore?
    
    weak var viewController: UIViewController?
}
