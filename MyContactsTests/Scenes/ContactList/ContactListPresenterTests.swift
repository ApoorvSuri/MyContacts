//
//  ContactListPresenterTests.swift
//  MyContactsTests
//
//  Created by Apoorv Suri on 31/08/20.
//  Copyright © 2020 Apoorv Suri. All rights reserved.
//

import XCTest
@testable import MyContacts

class ContactListPresenterTests: XCTestCase {
    var sut: ContactListPresenter!
    var spyViewController: ContactListDisplayLogicSpy!
    
    override func setUp() {
        sut = ContactListPresenter()
        spyViewController = ContactListDisplayLogicSpy()
        sut.viewController = spyViewController
    }
    
    func test_show_contacts() {
        //When
        sut.showContacts(ContactsListUseCases.ContactList.Response(contacts: []))
        //Then
        XCTAssertTrue(spyViewController.showContactsCalled)
    }
}

class ContactListDisplayLogicSpy: ContactListDisplayLogic {
    var showContactsCalled = false
    func showContacts(_ viewModel: ContactsListUseCases.ContactList.ViewModel) {
        showContactsCalled = true
    }
    
    var showSearchedContacts = false
    func showSearchedContacts(_ viewModel: ContactsListUseCases.ContactList.ViewModel) {
        showSearchedContacts = true
    }
    
    func removeContact(_ contact: ContactsListUseCases.ContactModel) {
        
    }
    
    func updateContact(_ contact: ContactsListUseCases.ContactModel) {
        
    }
    
    func createContact(_ contact: ContactsListUseCases.ContactModel) {
        
    }
    
    func showError(_ title: String?, message: String?) {
        
    }
}
