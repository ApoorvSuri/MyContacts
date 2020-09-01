//
//  RecentsViewController.swift
//  MyContacts
//
//  Created by Apoorv Suri on 30/08/20.
//  Copyright © 2020 Apoorv Suri. All rights reserved.
//

import UIKit

protocol RecentsDisplayLogic: class {
    func showRecentContacts(_ viewModel: RecentsUseCases.RecentContactList.ViewModel)
    func showError(_ title: String?, message: String?)
}

class RecentsViewController: UIViewController, RecentsDisplayLogic {
    
    //MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - iVars
    
    public var interactor: RecentsBusinessLogic?
    public var router: (RecentsRoutingLogic & RecentsDataPassing)?
    
    fileprivate var recentContactsViewModel: RecentsUseCases.RecentContactList.ViewModel?
    
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
        
        let router = RecentsRouter()
        let interactor = RecentsInteractor()
        let worker = RecentsWorker(withDataSource: RecentsLocalDataSource())
        let presenter = RecentsPresenter()
        
        viewController.interactor = interactor
        viewController.router = router
        
        interactor.worker = worker
        interactor.presenter = presenter
        
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        interactor?.getAllRecentContacts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    //MARK: - RecentsDisplayLogic
    
    func showRecentContacts(_ viewModel: RecentsUseCases.RecentContactList.ViewModel) {
        recentContactsViewModel = viewModel
        tableView.reloadData()
    }
    
    func showError(_ title: String?, message: String?) {
        let alertVC = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }
}

//MARK: - UITableViewDataSource

extension RecentsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentContactsViewModel?.recentContacts.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = recentContactsViewModel?.recentContacts[indexPath.row].name
        return cell
    }
}

//MARK: - UITableViewDelegate

extension RecentsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
