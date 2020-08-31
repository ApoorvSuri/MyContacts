//
//  ContactsListUseCases.swift
//  MyContacts
//
//  Created by Apoorv Suri on 30/08/20.
//  Copyright © 2020 Apoorv Suri. All rights reserved.
//

import Foundation

enum ContactsListUseCases {
    
    struct ContactModel {
        var identifier: String
        var name: String?
        var birthday: String?
        var phoneNumbers: [String]?
    }
    
    struct ContactList {
        
        struct Request {
            
        }
        
        struct Response {
            var contacts: [Contact]
        }
        
        struct ViewModel {
            var contacts: [ContactModel]
            var searchedContacts: [ContactModel]
            
            mutating func add(_ contact: ContactModel) {
                contacts.append(contact)
                contacts = contacts.sorted(by: {$0.name ?? "" < $1.name ?? "" })
            }
            
            mutating func remove(_ contact: ContactModel) {
                if let indexOfContact = contacts.firstIndex(where: {$0.identifier == contact.identifier}) {
                    contacts.remove(at: indexOfContact)
                }
            }
            
            mutating func update(_ contact: ContactModel) {
                if let indexOfContact = contacts.firstIndex(where: {$0.identifier == contact.identifier}) {
                    contacts[indexOfContact] = contact
                }
            }
        }
    }
    
    struct EditContact {
        struct Request {
            var contact: ContactModel
        }
        
        struct Response {
            var contact: Contact
        }
    }
    
    struct CreateContact {
        struct Response {
            var contact: Contact
        }
    }
}
