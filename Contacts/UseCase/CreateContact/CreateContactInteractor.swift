//
//  CreateContactInteractor.swift
//  Contacts
//
//  Created by nitin-7926 on 15/02/19.
//  Copyright © 2019 Nitin Singh. All rights reserved.
//

import Foundation

protocol CreateContactRequest {
    var firstName: String? { get }
    var middleName: String? { get }
    var lastName: String? { get }
    var email: String? { get }
    var phone: String? { get }
}

typealias CreateContactResponse = ContactResponse

struct CreateContactInteractor: UseCase {
    typealias Input = CreateContactRequest
    typealias Output = CreateContactResponse
    typealias UseCaseError = ContactError
    
    var dataStore: CreateContactDataStore?
    
    func process(_ input: Input, withCompletion completion: @escaping (Result<Output, UseCaseError>) -> Void) {
        guard [input.firstName, input.middleName, input.lastName, input.email, input.phone].unwrapRemovingNil().concat(byAppending: "").isEmpty == false else {
            completion(.failure(.initializationFailure(.noData)))
            return
        }
        let newContact = Contact(id: dataStore?.newContactId ?? 100_000_000, firstName: input.firstName, middleName: input.middleName, lastName: input.lastName, email: input.email, phone: input.phone)
        
        if case let Result.failure(err) = newContact.validateEmailPhone() {
            completion(.failure(err))
            return
        }
        
        guard let dataStore = dataStore else {
            completion(.success(newContact))
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            dataStore.createContact(usingDetail: newContact, withCompletion: { response in
                DispatchQueue.main.async {
//                    Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { _ in
                        switch response {
                        case .success(let result):
                            completion(.success(result))
                        case .failure(let reason): completion(.failure(.persistenceFailure(reason)))
                        }
//                    })
                }
            })
        }
    }
}


// MARK: DataStore Boundary

typealias CreateContactDataStoreRequest = CreateContactResponse
typealias CreateContactDataStoreResponse = CreateContactResponse

protocol CreateContactDataStore {
    var newContactId: Int { get }
    func createContact(usingDetail data: CreateContactDataStoreRequest, withCompletion completion: (Result<CreateContactDataStoreResponse, PersistenceError>) -> Void)
}

