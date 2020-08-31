//
//  ContactsService.swift
//  MyContacts
//
//  Created by Apoorv Suri on 29/08/20.
//  Copyright © 2020 Apoorv Suri. All rights reserved.
//

import Foundation
import Contacts
import ContactsUI

struct Contact {
    var identifier: String
    var name: String?
    var emails: [String]?
    var birthday: String?
    var phoneNumbers: [String]?
    var isDeleted = false
    
    init?(contact: CNContact?) {
        guard let contact = contact else { return nil }
        identifier = contact.identifier
        name = contact.givenName
        emails = contact.emailAddresses.compactMap({$0.value as String})
        
        if let contactBirthdayComponents = contact.birthday
            , let joinedBirthdayComponents = getDateStringFromComponents(dateComponents: contactBirthdayComponents) {
            
            birthday = joinedBirthdayComponents
        }
        
        phoneNumbers = contact.phoneNumbers.compactMap({$0.value.stringValue})
    }
    
    func getDateStringFromComponents(dateComponents: DateComponents) -> String? {
        if let date = Calendar.current.date(from: dateComponents) {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateStyle = DateFormatter.Style.medium
            let dateString = dateFormatter.string(from: date)
            
            return dateString
        }
        return nil
    }
}

protocol ContactsServiceProvider {
    func requestForAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void)
}

protocol ContactsServiceDelegate {
    func didUpdate(contact: Contact)
    func didDelete(contact: Contact)
    func didCreate(contact: Contact)
    func didFetch(contacts: [Contact])
}

class ContactsService: NSObject {
    
    static let shared = ContactsService()
    
    var delegate: ContactsServiceDelegate?
    
    private let contactStore: CNContactStore = CNContactStore()
    private let contactAttributes = [CNContactGivenNameKey, CNContactFamilyNameKey]
    
    fileprivate var createContactHandler: ((_ contact: Contact?) -> Void)?
    fileprivate var updateContactHandler: ((_ contact: Contact) -> Void)?
    
    fileprivate var contactBeingUpdated: Contact?
    
    
    
    private override init() {
        super.init()
        addObserver()
    }
    
    public func requestForAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        DispatchQueue.global().async {
            let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
            
            switch authorizationStatus {
            case .authorized:
                DispatchQueue.main.async {
                    completionHandler(true)
                }
            case .denied, .notDetermined:
                self.contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (access, accessError) in
                    DispatchQueue.main.async {
                        completionHandler(access)
                        if let error = accessError {
                            debugPrint("Unable to access contacts, error -> \(String(describing: error.localizedDescription))")
                        }
                    }
                })
            default:
                completionHandler(false)
            }
        }
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.addressBookDidChange),
            name: NSNotification.Name.CNContactStoreDidChange,
            object: nil)
    }
    
    @objc private func addressBookDidChange() {
        //Check if accessed contact was deleted from Contacts database
        if var contact = contactBeingUpdated {
            let fetchedContact = fetch(contactID: contact.identifier)
            if fetchedContact != nil {
                updateContactHandler?(Contact.init(contact: fetchedContact)!)
            } else {
                contact.isDeleted = true
                updateContactHandler?(contact)
                UIApplication.shared.windows.first?.visibleViewController?.navigationController?.popToRootViewController(animated: true)
            }
            updateContactHandler = nil
            contactBeingUpdated = nil
        }
    }
}

//MARK: CRUD Operations

extension ContactsService {
    
    public func fetchContacts(forName name: String, completion: @escaping ((_ contacts: [Contact]) -> Void)) {
        
        DispatchQueue.global().async {[unowned self] in
            
            let predicate = CNContact.predicateForContacts(matchingName: name)
            let keys = [CNContactViewController.descriptorForRequiredKeys()]
            
            var contacts: [CNContact] = []
            
            do {
                contacts = try self.contactStore.unifiedContacts(matching: predicate, keysToFetch: keys)
            } catch {}
            
            DispatchQueue.main.async {
                let parsedContacts = contacts.compactMap({ Contact.init(contact: $0)})
                completion(parsedContacts)
            }
        }
    }
    
    public func fetchAllContacts(completion: @escaping ((Result<[Contact],Error>) -> Void)) {
        DispatchQueue.global().async {[unowned self] in
            var contacts = [Contact]()
            let keysToFetch = [CNContactViewController.descriptorForRequiredKeys()]
            let request = CNContactFetchRequest(keysToFetch: keysToFetch)
            request.sortOrder = .givenName
            
            do {
                try self.contactStore.enumerateContacts(with: request) {(contact, stop) in
                    if !stop.pointee.boolValue {
                        contacts.append(Contact(contact: contact)!)
                    }
                }
            } catch let error {
                completion(.failure(error))
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(contacts))
            }
        }
    }
    
    public func createContact(completion: @escaping ((_ contact: Contact?) -> Void)) {
        createContactHandler = completion
        let vc = CNContactViewController(forNewContact: nil)
        vc.delegate = self
        UIApplication.shared.windows.first?.visibleViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    public func fetch(contactID: String) -> CNContact? {
        do {
            let contactRefetched = try contactStore.unifiedContact(withIdentifier: contactID, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
            return contactRefetched
        } catch let error {}
        return nil
    }
    
    public func updateContact(contactID: String, completion: @escaping ((_ contact: Contact) -> Void)) {
        let keys = [CNContactFamilyNameKey, CNContactEmailAddressesKey, CNContactBirthdayKey, CNContactImageDataKey]
        if let contact = fetch(contactID: contactID) {
            contactBeingUpdated = Contact(contact: contact)
            updateContactHandler = completion
            
            let contactViewController = CNContactViewController(for: contact)
            contactViewController.allowsActions = true
            contactViewController.allowsEditing = true
            contactViewController.contactStore = contactStore
            contactViewController.delegate = self
            contactViewController.displayedPropertyKeys = keys
            UIApplication.shared.windows.first?.visibleViewController?.navigationController?.pushViewController(contactViewController, animated: true)
        } else {
            fatalError("Unable to fetch contact")
        }
    }
}

extension ContactsService: CNContactViewControllerDelegate {
    
    func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
        return true
    }
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        if let modifiedContact = contact {
            createContactHandler?(Contact.init(contact: modifiedContact))
        }
        createContactHandler = nil
        UIApplication.shared.windows.first?.visibleViewController?.navigationController?.popToRootViewController(animated: true)
    }
}
