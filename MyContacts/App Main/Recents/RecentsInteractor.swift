//
//  RecentsInteractor.swift
//  MyContacts
//
//  Created by Apoorv Suri on 01/09/20.
//  Copyright © 2020 Apoorv Suri. All rights reserved.
//

import Foundation

protocol RecentsBusinessLogic {
    func getAllRecentContacts()
}

protocol RecentsDataStore {
    
}

class RecentsInteractor: RecentsBusinessLogic, RecentsDataStore {
    
    var presenter: RecentsPresentationLogic?
    var worker: RecentsWorker?
    
    func getAllRecentContacts() {
        worker?.getAllRecentContacts(completion: {[weak self] (result) in
            switch result {
            case .failure(let error):
                self?.presenter?.showError(error)
            case .success(let contacts):
                self?.presenter?.showRecentContacts(RecentsUseCases.RecentContactList.Response(contacts: contacts))
            }
        })
    }
}
