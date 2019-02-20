//
//  EditContactInteractor.swift
//  Contacts
//
//  Created by nitin-7926 on 15/02/19.
//  Copyright © 2019 Nitin Singh. All rights reserved.
//

import Foundation

// MARK: Usecase manifestation
struct EditContactInteractor: UseCase {
    var dataStore: EditContactDataStore?
    
    func process(_ input: ContactResponse, withCompletion completion: @escaping (Result<ContactResponse, ContactError>) -> Void) {
        let contact = Contact(id: input.id, firstName: input.firstName, middleName: input.middleName, lastName: input.lastName, email: input.email, phone: input.phone)
        
        if case let Result.failure(err) = contact.validateEmailPhone() {
            completion(.failure(err))
            return
        }
        
        guard let dataStore = dataStore else { completion(.success(contact)); return }
        DispatchQueue.global(qos: .userInitiated).async {
            dataStore.updateDetails(of: contact, withCompletion: { response in
                DispatchQueue.main.async {
                    switch response {
                    case .success(let result):
                        completion(.success(result))
                    case .failure(let reason): completion(.failure(.persistenceFailure(reason)))
                    }
                }
            })
        }
    }
}

// MARK: DataStore Boundary
//typealias EditContactDataStoreRequest = ContactResponse
//typealias EditContactDataStoreResponse = ContactResponse

protocol EditContactDataStore {
    func updateDetails(of contact: ContactResponse, withCompletion completion: (Result<ContactResponse, PersistenceError>) -> Void)
}
