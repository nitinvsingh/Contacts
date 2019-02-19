//
//  ViewController.swift
//  Contacts
//
//  Created by nitin-7926 on 14/02/19.
//  Copyright © 2019 Nitin Singh. All rights reserved.
//

import UIKit

class ListContactsViewController: UIViewController {
    
    @IBOutlet weak var contactList: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    private let interactor = ListContactsInteractor(dataStore: AppConfig.dataStore)
    
    private struct ContactRequest: ListContactsRequest {
        var searchCriteria: String?
    }
    
    private var contacts = [ListContactsPresenter.ViewModel]() {
        didSet {
            contactList.reloadData()
        }
    }
    
    private var showContactIndex: Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Contacts"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let allContactsRequest = ContactRequest(searchCriteria: nil)
        spinner.startAnimating()
        interactor.process(allContactsRequest) { [weak self] result in
            self?.spinner.stopAnimating()
            self?.spinner.stopAnimating()
            switch result {
            case .success(let usecaseOutput):
                let presenter = ListContactsPresenter()
                self?.contacts = presenter.generateViewModel(from: usecaseOutput)
            case .failure:
                let alert = UIAlertController(title: "Something went wrong", message: "An unexpected error occurred. Try killing the app and relaunching.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func createNewContact(_ sender: UIBarButtonItem) {
        let createContactVC = AppConfig.storyboard.instantiateViewController(withIdentifier: "createEditContactVC") as! CreateEditContactViewController
        createContactVC.presentationMode = .create
        self.navigationController?.pushViewController(createContactVC, animated: true)
    }
    
}

extension ListContactsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contactCell = tableView.dequeueReusableCell(withIdentifier: "contactCell") ?? UITableViewCell(style: .default, reuseIdentifier: "contactCell")
        contactCell.textLabel?.text = contacts[indexPath.row].name
        contactCell.detailTextLabel?.text = String(contacts[indexPath.row].id)
        return contactCell
    }
}

extension ListContactsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contactInfoVC = AppConfig.storyboard.instantiateViewController(withIdentifier: "contactInfoVC") as! ContactInfoViewController
        contactInfoVC.contactId = contacts[indexPath.row].id
        self.navigationController?.pushViewController(contactInfoVC, animated: true)
    }
}





