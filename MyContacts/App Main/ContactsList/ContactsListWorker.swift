//
//  ContactsListWorker.swift
//  MyContacts
//
//  Created by Apoorv Suri on 30/08/20.
//  Copyright © 2020 Apoorv Suri. All rights reserved.
//

import Foundation


enum ContactsWorkerError: Error {
    case accessNotGranted
    case fetchFailed
    case createFailed
}

protocol ContactsListDataSource {
    func fetchAllContacts(completion: @escaping ((Result<[Contact],ContactsWorkerError>) -> Void))
    func createContact(contact: Contact?, completion: @escaping ((Result<Contact, ContactsWorkerError>) -> Void))
    func updateContact(contactID: String, completion: @escaping ((Result<Contact, ContactsWorkerError>) -> Void))
    func findContact(forText text: String, completion: @escaping ((_ contacts: [Contact]) -> Void))
}

class ContactsListWorker {
    
    var datasource: ContactsListDataSource
    
    init(withDataSource datasource: ContactsListDataSource) {
        self.datasource = datasource
    }
    
    func fetchAllContacts(completion: @escaping ((Result<[Contact], ContactsWorkerError>) -> Void)) {
        datasource.fetchAllContacts(completion: completion)
    }
    
    func createContact(contact: Contact?, completion: @escaping ((Result<Contact, ContactsWorkerError>) -> Void)) {
        datasource.createContact(contact: contact, completion: completion)
    }
    
    func updateContact(contactID: String, completion: @escaping ((Result<Contact, ContactsWorkerError>) -> Void)) {
        datasource.updateContact(contactID: contactID, completion: completion)
    }
    
    func findContact(forText text: String, completion: @escaping ((_ contacts: [Contact]) -> Void)) {
        datasource.findContact(forText: text, completion: completion)
    }
}

class ContactsListLocalDataSource: ContactsListDataSource {
    
    func fetchAllContacts(completion: @escaping ((Result<[Contact], ContactsWorkerError>) -> Void)) {
        ContactsService.shared.requestForAccess { (isAccessGranted) in
            if isAccessGranted {
                ContactsService.shared.fetchAllContacts(completion: { (result) in
                    switch result {
                    case .success(let contacts):
                        completion(.success(contacts))
                    case .failure:
                        completion(.failure(.fetchFailed))
                    }
                })
            } else {
                completion(.failure(.accessNotGranted))
            }
        }
    }
    
    func createContact(contact: Contact?, completion: @escaping ((Result<Contact, ContactsWorkerError>) -> Void)) {
        ContactsService.shared.requestForAccess { (isAccessGranted) in
            if isAccessGranted {
                ContactsService.shared.createContact(completion: { (contact) in
                    if let contact = contact {
                        completion(.success(contact))
                    } else {
                        completion(.failure(.createFailed))
                    }
                })
            } else {
                completion(.failure(.accessNotGranted))
            }
        }
    }
    
    func updateContact(contactID: String, completion: @escaping ((Result<Contact, ContactsWorkerError>) -> Void)) {
        
        ContactsService.shared.requestForAccess { (isAccessGranted) in
            if isAccessGranted {
                ContactsService.shared.updateContact(contactID: contactID, completion: { (contact) in
                    completion(.success(contact))
                })
            } else {
                completion(.failure(.accessNotGranted))
            }
        }
    }
    
    func findContact(forText text: String, completion: @escaping ((_ contacts: [Contact]) -> Void)) {
        ContactsService.shared.fetchContacts(forName: text, completion: completion)
    }
}
