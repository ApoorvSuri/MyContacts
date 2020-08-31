//
//  ContactsListViewController.swift
//  MyContacts
//
//  Created by Apoorv Suri on 30/08/20.
//  Copyright © 2020 Apoorv Suri. All rights reserved.
//

import UIKit

protocol ContactListDisplayLogic: class {
    func showContacts(_ viewModel: ContactsListUseCases.ContactList.ViewModel)
    func showSearchedContacts(_ viewModel: ContactsListUseCases.ContactList.ViewModel)
    
    func removeContact(_ contact: ContactsListUseCases.ContactModel)
    func updateContact(_ contact: ContactsListUseCases.ContactModel)
    func createContact(_ contact: ContactsListUseCases.ContactModel)
    
    func showError(_ title: String?, message: String?)
}

class ContactsListViewController: UIViewController, ContactListDisplayLogic {
    
    
    
    //MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - iVars
    
    public var interactor: ContactsListBusinessLogic?
    public var router: (ContactListRoutingLogic & ContactListDataPassing)?
    
    fileprivate var searchController : UISearchController?
    fileprivate var isSearchActive: Bool { searchController?.isActive ?? false }
    fileprivate var contactsViewModel: ContactsListUseCases.ContactList.ViewModel?
    
    //MARK: - Init
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    //MARK: - VIP Setup
    
    func setup() {
        let viewController = self
        
        let router = ContactsListRouter()
        let interactor = ContactsListInteractor()
        let worker = ContactsListWorker(withDataSource: ContactsListLocalDataSource())
        let presenter = ContactListPresenter()
        
        viewController.interactor = interactor
        viewController.router = router
        
        interactor.worker = worker
        interactor.presenter = presenter
        
        presenter.viewController = viewController
        router.viewController = viewController
    }
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        setupSearchController()
        interactor?.getAllContacts()
    }
    
    //MARK: - UI
    
    func setupSearchController() {
        if navigationItem.searchController == nil {
            if searchController == nil {
                searchController = UISearchController(searchResultsController: nil)
                searchController?.hidesNavigationBarDuringPresentation = true
                searchController?.searchBar.placeholder = "Search"
                searchController?.delegate = self
                searchController?.searchResultsUpdater = self
                searchController?.dimsBackgroundDuringPresentation = false
                searchController?.searchBar.searchBarStyle = .minimal
            }
        }
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    
    //MARK: - Actions
    
    @IBAction func btnAddContactPressed(_ sender: Any) {
        interactor?.createNewContact()
    }
    
    //MARK: - ContactListDisplayLogic
    
    func showSearchedContacts(_ viewModel: ContactsListUseCases.ContactList.ViewModel) {
        if contactsViewModel != nil {
            contactsViewModel?.searchedContacts = viewModel.searchedContacts
        } else {
            contactsViewModel = viewModel
        }
        tableView.reloadData()
    }
    
    func showContacts(_ viewModel: ContactsListUseCases.ContactList.ViewModel) {
        self.contactsViewModel = viewModel
        self.tableView.reloadData()
    }
    
    func removeContact(_ contact: ContactsListUseCases.ContactModel) {
        self.contactsViewModel?.remove(contact)
        self.tableView.reloadData()
    }
    
    func updateContact(_ contact: ContactsListUseCases.ContactModel) {
        self.contactsViewModel?.update(contact)
        self.tableView.reloadData()
    }
    
    func createContact(_ contact: ContactsListUseCases.ContactModel) {
        self.contactsViewModel?.add(contact)
        self.tableView.reloadData()
    }
    
    func showError(_ title: String?, message: String?) {
        let alertVC = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }
}

//MARK: - UITableViewDataSource

extension ContactsListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchActive {
            return contactsViewModel?.searchedContacts.count ?? 0
        } else {
            return contactsViewModel?.contacts.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if isSearchActive {
            cell.textLabel?.text = contactsViewModel?.searchedContacts[indexPath.row].name
            cell.detailTextLabel?.text =  contactsViewModel?.searchedContacts[indexPath.row].phoneNumbers?.first
        } else {
            cell.textLabel?.text = contactsViewModel?.contacts[indexPath.row].name
            cell.detailTextLabel?.text =  contactsViewModel?.contacts[indexPath.row].phoneNumbers?.first
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate

extension ContactsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearchActive {
            if let contactModel = contactsViewModel?.searchedContacts[indexPath.row] {
                interactor?.editContact(ContactsListUseCases.EditContact.Request(contact: contactModel))
            }
        } else {
            if let contactModel = contactsViewModel?.contacts[indexPath.row] {
                interactor?.editContact(ContactsListUseCases.EditContact.Request(contact: contactModel))
            }
        }
    }
}

//MARK:- Delegate : Search Display Controller
extension ContactsListViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text!.count > 0 {
            interactor?.searchContacts(forText: searchController.searchBar.text!)
        }
    }
}

//MARK:- Delegate : Search Controller
extension ContactsListViewController : UISearchControllerDelegate {
    
    func didDismissSearchController(_ searchController: UISearchController) {
        contactsViewModel?.searchedContacts = []
        tableView.reloadData()
    }
}
