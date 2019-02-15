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

protocol CreateContactResponse {
    var id: Int { get }
    var firstName: String? { get }
    var middleName: String? { get }
    var lastName: String? { get }
    var email: String? { get }
    var phone: String? { get }
}

extension Contact: CreateContactResponse {}

struct CreateContactInteractor: UseCase {
    typealias Input = CreateContactRequest
    typealias Output = CreateContactResponse
    typealias UseCaseError = CreateContactError
    
    var dataStore: CreateContactDataStore?
    
    func process(_ input: CreateContactRequest, withCompletion completion: (Result<CreateContactResponse, CreateContactError>) -> Void) {
        guard [input.firstName, input.middleName, input.lastName, input.email, input.phone].unwrapRemovingNil().isEmpty == false else {
            completion(.failure(.initializationFailure(.noData)))
            return
        }
        let newContact = Contact(id: 100, firstName: input.firstName, middleName: input.middleName, lastName: input.lastName, email: input.email, phone: input.phone)
        // dataStore?.createContact(usingDetail: newContact)
        completion(.success(newContact))
    }
}




protocol CreateContactDataStore {
    func createContact(usingDetail: Contact, withCompletion completion: () -> Void)
}

enum CreateContactError: Error {
    case initializationFailure(Reason)
    case persistenceFailure(Reason)
    
    enum Reason {
        case noData
        case invalidFieldData(fieldName: String)
    }
}
