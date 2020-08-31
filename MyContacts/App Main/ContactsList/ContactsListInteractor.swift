//
//  ContactsListInteractor.swift
//  MyContacts
//
//  Created by Apoorv Suri on 30/08/20.
//  Copyright © 2020 Apoorv Suri. All rights reserved.
//

import Foundation

protocol ContactsListBusinessLogic {
    func getAllContacts()
    func editContact(_ request: ContactsListUseCases.EditContact.Request)
    func createNewContact()
    
    func searchContacts(forText text: String)
}

protocol ContactListDataStore {
    
}

class ContactsListInteractor: ContactsListBusinessLogic, ContactListDataStore {
        
    var presenter: ContactListPresentationLogic?
    var worker: ContactsListWorker?
    
    func getAllContacts() {
        worker?.fetchAllContacts(completion: {[weak self] (result) in
            switch result {
            case .failure(let error):
                self?.presenter?.showError(error)
            case .success(let contacts):
                self?.presenter?.showContacts(ContactsListUseCases.ContactList.Response(contacts: contacts))
            }
        })
    }
    
    func editContact(_ request: ContactsListUseCases.EditContact.Request) {
        worker?.updateContact(contactID: request.contact.identifier, completion: {[weak self] (result) in
            switch result {
            case .failure(let error):
                self?.presenter?.showError(error)
            case .success(let contact):
                self?.presenter?.showEditContactCompletion(ContactsListUseCases.EditContact.Response(contact: contact))
            }
        })
    }
    
    func createNewContact() {
        worker?.createContact(contact: nil, completion: {[weak self] (result) in
            
            switch result {
            case .failure(let error):
                self?.presenter?.showError(error)
            case .success(let contact):
                self?.presenter?.showCreateContactCompletion(ContactsListUseCases.CreateContact.Response(contact: contact))
            }
        })
    }
    
    func searchContacts(forText text: String) {
        worker?.findContact(forText: text, completion: {[weak self] (contacts) in
            self?.presenter?.showSearchedContacts(ContactsListUseCases.ContactList.Response(contacts: contacts))
        })
    }
}
