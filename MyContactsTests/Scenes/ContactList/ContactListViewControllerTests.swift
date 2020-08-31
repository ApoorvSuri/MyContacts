//
//  ContactListViewControllerTests.swift
//  MyContactsTests
//
//  Created by Apoorv Suri on 31/08/20.
//  Copyright © 2020 Apoorv Suri. All rights reserved.
//

import XCTest
@testable import MyContacts

class ContactListViewControllerTests: XCTestCase {
    var sut: ContactsListViewController!
    var interactor: ContactListInteractorSpy!
    var window: UIWindow = UIWindow()
    
    override func setUp() {
        sut = ContactsListViewController(nibName: nil, bundle: nil)
        interactor = ContactListInteractorSpy()
        sut.interactor = interactor
        loadView()
    }
    
    func loadView() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }
    
    func test_fetch_contacts() {
        sut.viewDidLoad()
        XCTAssertTrue(interactor.getAllContactsCalled)
    }
}

class ContactListInteractorSpy: ContactsListBusinessLogic, ContactListDataStore {
    var getAllContactsCalled = false
    func getAllContacts() {
        getAllContactsCalled = true
    }
    
    func editContact(_ request: ContactsListUseCases.EditContact.Request) {}
    func createNewContact() {}
    func searchContacts(forText text: String) {}
}
