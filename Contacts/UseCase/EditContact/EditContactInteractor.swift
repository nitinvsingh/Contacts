//
//  EditContactInteractor.swift
//  Contacts
//
//  Created by nitin-7926 on 15/02/19.
//  Copyright © 2019 Nitin Singh. All rights reserved.
//

import Foundation

// MARK: Data Boundary
protocol EditContactRequest: CreateContactRequest {
    var id: Int { get }
}
typealias EditContactResponse = CreateContactResponse

struct EditContactInteractor: UseCase {
    typealias UseCaseError = EditContactError
    typealias Input = EditContactRequest
    typealias Output = EditContactResponse
    
    private var dataStore: EditContactDataStore?
    
    func process(_ input: EditContactRequest, withCompletion completion: (Result<EditContactResponse, EditContactError>) -> Void) {
        // 1. Validate individual field condition
        
        // 2. Update the record in data store.
        let contact = Contact(id: input.id, firstName: input.firstName, middleName: input.middleName, lastName: input.lastName, email: input.email, phone: input.phone)
        
        // 3. dataStore.updateDetails(of contact, withCompletion: (Contact) -> Void)
        completion(.success(contact))
    }
}

enum EditContactError: Error {
    
    var localizedDescription: String {
        return "Error occurred while editing contact"
    }
}

protocol EditContactDataStore {
    func updateDetails(of contact: Contact, withCompletion completion: (Contact) -> Void)
}



