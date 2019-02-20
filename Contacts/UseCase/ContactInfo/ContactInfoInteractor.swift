//
//  ContactInfoInteractor.swift
//  Contacts
//
//  Created by Nitin Singh on 17/02/19.
//  Copyright © 2019 Nitin Singh. All rights reserved.
//

import Foundation

// MARK: Usecase Data Boundary
//typealias ContactInfoResponse = ContactResponse

// MARK: Usecase manifestation
struct ContactInfoInteractor: UseCase {
//    typealias Input = ContactId
//    typealias Output = ContactInfoResponse
//    typealias UseCaseError = ContactError
    
    var dataStore: ContactInfoDataStore?
    
    func process(_ input: ContactId, withCompletion completion: @escaping (Result<ContactResponse, ContactError>) -> Void) {
        guard let dataStore = dataStore else {
            completion(.failure(.persistenceUnavailble))
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            dataStore.getContactInfo(forId: input, withCompletion: { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        completion(.success(response))
                    case .failure(let reason):
                        switch reason {
                        case .invalidContactKey: completion(.failure(.invalidRequest(.invalidContactId)))
                        default:
                            completion(.failure(ContactError.invalidRequest(ContactError.ContactErrorReason.noData)))
                        }
                    }
                    
                }
            })
        }
    }
}

// MARK: Data Store Boundary
//typealias ContactInfoDataStoreResponse = ContactInfoResponse

protocol ContactInfoDataStore {
    func getContactInfo(forId id: ContactId, withCompletion completion: @escaping (Result<ContactResponse, PersistenceError>) -> Void)
}
