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
    typealias Output = [ListContactsResponse]
    typealias UseCaseError = ContactError
    
    var dataStore: ListContactsDataStore?
    
    func process(_ input: Input, withCompletion completion: @escaping (Result<Output, UseCaseError>) -> Void) {
        // Notify that the dataStore isn't configured and the request cannot be fulfilled.
        guard let dataStore = dataStore else {
            // A bug can be reported stating persitence isn't available.
            completion(.failure(.persistenceUnavailble))
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.global(qos: .userInitiated).async {
                dataStore.getContacts(matching: input.searchCriteria) { response in
                    DispatchQueue.main.async {
//                        Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { _ in
                            switch response {
                            case .success(let result): completion(.success(result))
                            case .failure(let err): completion(.failure(.persistenceFailure(err)))
                            } 
//                        })
                    }
                }
            }
        }
    }
}

// MARK: DataStore Boundary
typealias ListContactsDataStoreResponse = ListContactsResponse
protocol ListContactsDataStore {
    func getContacts(matching criteria: String?, withCompletion: @escaping (Result<[ListContactsDataStoreResponse], PersistenceError>) -> Void)
}
