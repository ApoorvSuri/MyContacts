//
//  ContactsListPresenter.swift
//  MyContacts
//
//  Created by Apoorv Suri on 30/08/20.
//  Copyright © 2020 Apoorv Suri. All rights reserved.
//

import Foundation

protocol ContactListPresentationLogic {
    func showContacts(_ response: ContactsListUseCases.ContactList.Response)
    func showSearchedContacts(_ response: ContactsListUseCases.ContactList.Response)
    func showEditContactCompletion(_ response: ContactsListUseCases.EditContact.Response)
    func showCreateContactCompletion(_ response: ContactsListUseCases.CreateContact.Response)
    func showError(_ error: ContactsWorkerError)
}

class ContactListPresenter: ContactListPresentationLogic {
    
    var viewController: ContactListDisplayLogic?
    
    func showContacts(_ response: ContactsListUseCases.ContactList.Response) {
        
        let parsedContacts = response.contacts.compactMap({
            ContactsListUseCases.ContactModel(identifier: $0.identifier, name: $0.name, birthday: $0.birthday, phoneNumbers: $0.phoneNumbers)
        })
        
        let viewModel = ContactsListUseCases.ContactList.ViewModel(contacts: parsedContacts, searchedContacts: [])
        
        viewController?.showContacts(viewModel)
    }
    
    func showEditContactCompletion(_ response: ContactsListUseCases.EditContact.Response) {
        let parsedContact = ContactsListUseCases.ContactModel(identifier: response.contact.identifier
            , name: response.contact.name
            , birthday: response.contact.birthday
            , phoneNumbers: response.contact.phoneNumbers)
        
        if !response.contact.isDeleted {
            viewController?.updateContact(parsedContact)
        } else {
            viewController?.removeContact(parsedContact)
        }
    }
    
    func showCreateContactCompletion(_ response: ContactsListUseCases.CreateContact.Response) {
        let parsedContact = ContactsListUseCases.ContactModel(identifier: response.contact.identifier
            , name: response.contact.name
            , birthday: response.contact.birthday
            , phoneNumbers: response.contact.phoneNumbers)
        
        viewController?.createContact(parsedContact)
    }
    
    func showError(_ error: ContactsWorkerError) {
        var title: String?
        var message: String?
        switch error {
        case .accessNotGranted:
            title = "Access denied!"
            message = "Could not access your contacts, please check your permissions and try again."
        case .createFailed:
            title = "Create contact failed!"
            message = "Could not create contact"
            
        case .fetchFailed:
            title = "Fetch failed"
            message = "Could not fetch your contacts"
        }
        
        viewController?.showError(title, message: message)
    }
    
    func showSearchedContacts(_ response: ContactsListUseCases.ContactList.Response) {
        let parsedContacts = response.contacts.compactMap({
            ContactsListUseCases.ContactModel(identifier: $0.identifier, name: $0.name, birthday: $0.birthday, phoneNumbers: $0.phoneNumbers)
        })
        let viewModel = ContactsListUseCases.ContactList.ViewModel(contacts: [], searchedContacts: parsedContacts)
        viewController?.showSearchedContacts(viewModel)
    }
}
