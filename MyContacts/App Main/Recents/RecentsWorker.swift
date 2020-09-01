//
//  RecentsWorker.swift
//  MyContacts
//
//  Created by Apoorv Suri on 01/09/20.
//  Copyright © 2020 Apoorv Suri. All rights reserved.
//

import Foundation

enum RecentsWorkerError: Error {
    case noRecentContacts
}

protocol RecentsDataSource {
    func getAllRecentContacts(completion: @escaping ((Result<[Contact],RecentsWorkerError>) -> Void))
}

class RecentsWorker {
    var datasource: RecentsDataSource
    
    init(withDataSource datasource: RecentsDataSource) {
        self.datasource = datasource
    }
    
    func getAllRecentContacts(completion: @escaping ((Result<[Contact],RecentsWorkerError>) -> Void)) {
        datasource.getAllRecentContacts(completion: completion)
    }
}

class RecentsLocalDataSource: RecentsDataSource {
    
    func getAllRecentContacts(completion: @escaping ((Result<[Contact],RecentsWorkerError>) -> Void)) {
        let fetchedContacts = ContactsService.shared.getAllRecentContacts()
        completion( fetchedContacts.count == 0 ? .failure(RecentsWorkerError.noRecentContacts) : .success(fetchedContacts))
    }
}
