//
//  RecentsPresenter.swift
//  MyContacts
//
//  Created by Apoorv Suri on 01/09/20.
//  Copyright © 2020 Apoorv Suri. All rights reserved.
//

import Foundation

protocol RecentsPresentationLogic {
    func showRecentContacts(_ response: RecentsUseCases.RecentContactList.Response)
    func showError(_ error: RecentsWorkerError)
}

class RecentsPresenter: RecentsPresentationLogic {
    
    weak var viewController: RecentsDisplayLogic?
    
    func showRecentContacts(_ response: RecentsUseCases.RecentContactList.Response) {
        let parsedContacts = response.contacts.reversed().compactMap({
            RecentsUseCases.ContactModel(identifier: $0.identifier, name: $0.name)
        })
        
        let viewModel = RecentsUseCases.RecentContactList.ViewModel(recentContacts: parsedContacts)
        
        viewController?.showRecentContacts(viewModel)
    }
    
    func showError(_ error: RecentsWorkerError) {
        var title: String?
        var message: String?
        switch error {
        case .noRecentContacts:
            title = "No Recent Contacts"
        }
        
        viewController?.showError(title, message: message)
    }
}
