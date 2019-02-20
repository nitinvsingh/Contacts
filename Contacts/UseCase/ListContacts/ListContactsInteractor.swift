//
//  ListContactsInteractor.swift
//  Contacts
//
//  Created by nitin-7926 on 16/02/19.
//  Copyright © 2019 Nitin Singh. All rights reserved.
//

import Foundation

// MARK: Usecase Data Boundary
//protocol ListContactsRequest {
//    var searchCriteria: String? { get }
//}
//typealias ListContactsResponse = ContactResponse

// MARK: Usecase manifestation
struct ListContactsInteractor: UseCase {
    var dataStore: ListContactsDataStore?
    
    func process(_ input: SearchCriteria?, withCompletion completion: @escaping (Result<[ContactResponse], ContactError>) -> Void) {
        // Notify that the dataStore isn't configured and the request cannot be fulfilled.
        guard let dataStore = dataStore else {
            // A bug can be reported stating persitence isn't available.
            completion(.failure(.persistenceUnavailble))
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.global(qos: .userInitiated).async {
                dataStore.getContacts(matching: input) { response in
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
}

// MARK: DataStore Boundary
//typealias ListContactsDataStoreResponse = ListContactsResponse

protocol ListContactsDataStore {
    func getContacts(matching criteria: SearchCriteria?, withCompletion: @escaping (Result<[ContactResponse], PersistenceError>) -> Void)
}
