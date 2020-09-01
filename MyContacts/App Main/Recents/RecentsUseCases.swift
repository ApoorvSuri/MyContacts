//
//  RecentsUseCases.swift
//  MyContacts
//
//  Created by Apoorv Suri on 01/09/20.
//  Copyright © 2020 Apoorv Suri. All rights reserved.
//

import Foundation

enum RecentsUseCases {
    
    struct ContactModel {
        var identifier: String
        var name: String?
    }
    
    struct RecentContactList {
        
        struct Response {
            var contacts: [Contact]
        }
        
        struct ViewModel {
            var recentContacts: [ContactModel]
        }
    }
}
