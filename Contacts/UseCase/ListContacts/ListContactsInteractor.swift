//
//  ListContactsInteractor.swift
//  Contacts
//
//  Created by nitin-7926 on 16/02/19.
//  Copyright © 2019 Nitin Singh. All rights reserved.
//

import Foundation

// MARK: Data Boundary
protocol ListContactsRequest {
    var searchCriteria: String? { get }
}

typealias ListContactsResponse = ContactResponse

// MARK: Usecase
struct ListContactsInteractor: UseCase {
    typealias Input = ListContactsRequest
    typealias Output = [ListContactsResponse]?
    typealias UseCaseError = ListContactsError
    
    var dataStore: ListContactsDataStore?
    
    func process(_ input: Input, withCompletion completion: @escaping (Result<Output, UseCaseError>) -> Void) {
        // Notify that the dataStore isn't configured and the request cannot be fulfilled.
        guard let dataStore = dataStore else {
            // A bug can be reported stating persitence isn't available.
            completion(.failure(.persistenceUnavailable))
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            dataStore.getContacts(matching: input.searchCriteria) { response in
                DispatchQueue.main.async {
                    switch response {
                    case .success(let result): completion(.success(result))
                    case .failure(let err): completion(.failure(.persistenceFailure(err)))
                    }
                }
            }
        }
    }
}

enum ListContactsError: Error {
    case persistenceUnavailable
    case persistenceFailure(PersistenceError)
    
    var localizedDescription: String {
        return ""
    }
}

// MARK: DataStore Boundary
typealias ListContactsDataStoreResponse = ListContactsResponse
protocol ListContactsDataStore {
    func getContacts(matching criteria: String?, withCompletion: @escaping (Result<[ListContactsDataStoreResponse]?, PersistenceError>) -> Void)
}

struct MockDS: ListContactsDataStore {
    struct MockResponse: ListContactsDataStoreResponse {
        let id: Int
        var firstName: String?
        var middleName: String?
        var lastName: String?
        let email: String?
        let phone: String?
    }
    
    func getContacts(matching criteria: String?, withCompletion: (Result<[ListContactsDataStoreResponse]?, PersistenceError>) -> Void) {
        
    }
}
