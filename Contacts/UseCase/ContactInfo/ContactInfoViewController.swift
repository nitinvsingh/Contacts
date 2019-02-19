//
//  ContactInfoViewController.swift
//  Contacts
//
//  Created by nitin-7926 on 18/02/19.
//  Copyright © 2019 Nitin Singh. All rights reserved.
//

import UIKit

class ContactInfoViewController: UITableViewController {
    
    var contactId: Int? = nil
    var contact: ContactInfoPresenter.ViewModel? {
        didSet {
            if let contact = contact {
                toggleSpinnerOn(false)
                fullNameLabel.text = contact.displayName
                emailLabel.text = contact.email
                phoneLabel.text = contact.phone
                deleteButton.isEnabled = true
                tableView.reloadData()
            }
        }
    }
    
    private struct DeleteContactRequestMock: DeleteContactRequest {
        let id: Int
    }
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    private let interactor = ContactInfoInteractor(dataStore: AppConfig.dataStore)
    
    struct ContactInfoRequestMock: ContactInfoRequest {
        let contactId: Int
    }
    
    lazy var editBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editContact))
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        toggleSpinnerOn(true)
        interactor.process(ContactInfoRequestMock(contactId: contactId!)) { [weak self] response in
            self?.toggleSpinnerOn(false)
            switch response {
            case .success(let result):
                self?.contact = ContactInfoPresenter().generateViewModel(from: result)
            case .failure(let err):
                switch err {
                case .invalidRequest:
                    let alert = UIAlertController(title: "Invalid Contact", message: "The request seems invalid", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                        self?.navigationController?.popViewController(animated: true)
                    }))
                    self?.present(alert, animated: true, completion: nil)
                default:
                    let alert = UIAlertController(title: "Something went wrong", message: "An unexpected error occurred.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in  self?.navigationController?.popViewController(animated: true) }))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func toggleSpinnerOn(_ turnOn: Bool) {
        deleteButton.isHidden = turnOn
        navigationItem.rightBarButtonItem = turnOn ? nil : editBarButton
        turnOn ? spinner.startAnimating() : spinner.stopAnimating()
    }
    
    @objc private func editContact() {
        guard let contact = contact else { return }
        let editContactVC = AppConfig.storyboard.instantiateViewController(withIdentifier: "createEditContactVC") as! CreateEditContactViewController
        editContactVC.presentationMode = .edit(contact: contact)
        self.navigationController?.pushViewController(editContactVC, animated: true)
    }
    
    @IBAction func deleteContact(_ sender: UIButton) {
        let alert = UIAlertController(title: "Delete Contact?", message: "This change cannot be undone.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            let deleteContactUseCase = DeleteContactInteractor(dataStore: AppConfig.dataStore)
            guard let contactId = self.contact?.id else { return }
            let deleteRequest = DeleteContactRequestMock(id: contactId)
            deleteContactUseCase.process(deleteRequest) { [weak self] response in
                switch response {
                case .success:
                    self?.navigationController?.popViewController(animated: true)
                case .failure:
                    let alert = UIAlertController(title: "Invalid Request", message: "An unexpected error occurred.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                        self?.navigationController?.popViewController(animated: true)
                    }))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
