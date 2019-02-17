//
//  ContactInfoInteractor.swift
//  Contacts
//
//  Created by Nitin Singh on 17/02/19.
//  Copyright © 2019 Nitin Singh. All rights reserved.
//

import Foundation

// MARK: Boundary
protocol ContactInfoRequest {
    var contactId: Int { get }
}

typealias ContactInfoResponse = ContactResponse

struct ContactInfoInteractor: UseCase {
    typealias Input = ContactInfoRequest
    typealias Output = ContactInfoResponse
    typealias UseCaseError = ContactInfoError
    
    var dataStore: ContactInfoDataStore?
    
    func process(_ input: Input, withCompletion completion: @escaping (Result<Output, UseCaseError>) -> Void) {
        guard let dataStore = dataStore else { completion(.failure(.persistenceNotAvailable)); return }
        DispatchQueue.global(qos: .userInitiated).async {
            dataStore.getContactInfo(forId: input.contactId, withCompletion: { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response): completion(.success(response))
                    case .failure: completion(.failure(.persistenceError))
                    }
                }
            })
        }
    }
}

protocol ContactInfoDataStore {
    func getContactInfo(forId id: Int, withCompletion completion: @escaping (Result<ContactInfoResponse, PersistenceError>) -> Void)
}

enum ContactInfoError: Error {
    case persistenceNotAvailable
    case persistenceError
    var localizedDescription: String { return "Contact info retrival error." }
}
