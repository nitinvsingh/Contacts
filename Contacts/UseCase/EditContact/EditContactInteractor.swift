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
typealias EditContactResponse = ContactResponse

// MARK: Usecase
struct EditContactInteractor: UseCase {
    typealias UseCaseError = EditContactError
    typealias Input = EditContactRequest
    typealias Output = EditContactResponse
    
    private var dataStore: EditContactDataStore?
    
    private let nonFirstEmailChars = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "_"]
    
    func process(_ input: EditContactRequest, withCompletion completion: @escaping (Result<EditContactResponse, EditContactError>) -> Void) {
        // 1. Validate individual field condition
        // like regex match for email
        // Email validation
        if let email = input.email, let firstChar = email.first, email.contains("@") == true {
            if let _ = nonFirstEmailChars.firstIndex(of: String(firstChar)) {
                completion(.failure(.invalidFieldData(fieldName: "email")))
                return
            }
        }
        // Phone validation
        if let phone = input.phone, phone.count < 8 {
            completion(.failure(.invalidFieldData(fieldName: "phone")))
            return
        }
        
        // 2. Create contact
        let contact = Contact(id: input.id, firstName: input.firstName, middleName: input.middleName, lastName: input.lastName, email: input.email, phone: input.phone)
        
        // 3. dataStore.updateDetails(of contact, withCompletion: (Contact) -> Void)
        guard let dataStore = dataStore else { completion(.success(contact)); return }
        DispatchQueue.global(qos: .userInitiated).async {
            dataStore.updateDetails(of: contact, withCompletion: { response in
                DispatchQueue.main.async {
//                    completion(response)
                }
            })
        }
    }
}

// MARK: DataStore Boundary
typealias EditContactDataStoreRequest = EditContactResponse
typealias EditContactDataStoreResponse = Bool

protocol EditContactDataStore {
    func updateDetails(of contact: EditContactDataStoreRequest, withCompletion completion: (Result<EditContactDataStoreResponse, PersistenceError>) -> Void)
}
