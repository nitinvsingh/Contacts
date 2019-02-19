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
    typealias Input = EditContactRequest
    typealias Output = EditContactResponse
    typealias UseCaseError = ContactError
    
    var dataStore: EditContactDataStore?
    
    private let nonFirstEmailChars = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "_"]
    
    func process(_ input: Input, withCompletion completion: @escaping (Result<Output, UseCaseError>) -> Void) {
        
//        if let email = input.email, email.isEmpty == false, let firstChar = email.first {
//            guard nonFirstEmailChars.firstIndex(of: String(firstChar)) == nil, email.contains("@")  else {
//                completion(.failure(.updateFailure(.invalidFieldData(fieldName: "email"))))
//                return
//            }
//        }
//
//        if let phone = input.phone, phone.isEmpty == false, phone.count < 8 {
//            completion(.failure(.updateFailure(.invalidFieldData(fieldName: "phone"))))
//            return
//        }
        
        
        
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
typealias EditContactDataStoreRequest = EditContactResponse
typealias EditContactDataStoreResponse = EditContactResponse

protocol EditContactDataStore {
    func updateDetails(of contact: EditContactDataStoreRequest, withCompletion completion: (Result<EditContactDataStoreResponse, PersistenceError>) -> Void)
}
