//
//  CreateContactViewController.swift
//  Contacts
//
//  Created by nitin-7926 on 18/02/19.
//  Copyright © 2019 Nitin Singh. All rights reserved.
//

import UIKit

class CreateEditContactViewController: UITableViewController {
    
    enum PresentationMode {
        case create
        case edit(contact: ContactResponse)
    }
    
    var presentationMode: PresentationMode = .create

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var middleNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var saveContactButton: UIButton!
    
    
    private struct CreateContactRequestMock: CreateContactRequest {
        let firstName: String?
        let middleName: String?
        let lastName: String?
        let email: String?
        let phone: String?
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch presentationMode {
        case .create:
            title = "New Contact"
        case .edit:
            title = "Edit Contact"
        }
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if case PresentationMode.edit(let contact) = presentationMode {
            firstNameField.text = contact.firstName
            middleNameField.text = contact.middleName
            lastNameField.text = contact.lastName
            emailField.text = contact.email
            phoneField.text = contact.phone
        }
    }
    
    @IBAction func saveContact(_ sender: UIButton) {
        let _self: CreateEditContactViewController? = self
        _self?.toggleSpinnerOn(true)
        func resolveUseCaseResponse(response: Result<ContactResponse, ContactError>) -> Void {
            _self?.toggleSpinnerOn(false)
            switch response {
            case .success:
                _self?.navigationController?.popViewController(animated: true)
            case .failure(let err):
                switch err {
                case .updateFailure(let reason), .initializationFailure(let reason), .invalidRequest(let reason):
                    switch reason {
                    case .invalidFieldData(let fieldName):
                        let alert = UIAlertController(title: "Invalid \(fieldName).", message: "Could not save contact as the \(fieldName) field has invalid data.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        _self?.present(alert, animated: true, completion: nil)
                    case .noData:
                        let alert = UIAlertController(title: "No data to create contact", message: "Any one of the above field should be provided to create contact.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        _self?.present(alert, animated: true, completion: nil)
                    default: break
                    }
                default: break
                }
            }
        }
        switch presentationMode {
        case .create:
            let newContactRequest = CreateContactRequestMock(firstName: firstNameField.text, middleName: middleNameField.text, lastName: lastNameField.text, email: emailField.text, phone: phoneField.text)
            let createInteractor = CreateContactInteractor(dataStore: AppConfig.dataStore)
            createInteractor.process(newContactRequest, withCompletion: resolveUseCaseResponse)
        case .edit(let contact):
            let editInteractor = EditContactInteractor(dataStore: AppConfig.dataStore)
            let editContactRequest = Contact(id: contact.id, firstName: firstNameField.text, middleName: middleNameField.text, lastName: lastNameField.text, email: emailField.text, phone: phoneField.text)
            editInteractor.process(editContactRequest, withCompletion: resolveUseCaseResponse)
        }
    }
    
    func toggleSpinnerOn(_ turnOn: Bool) {
        saveContactButton.isHidden = turnOn
        turnOn ? spinner.startAnimating() : spinner.stopAnimating()
    }
    
}
