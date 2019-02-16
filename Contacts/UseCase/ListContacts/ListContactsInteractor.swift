//
//  ListContactsInteractor.swift
//  Contacts
//
//  Created by nitin-7926 on 16/02/19.
//  Copyright © 2019 Nitin Singh. All rights reserved.
//

import Foundation

protocol ListContactsRequest {
    var searchCriteria: String? { get }
}

protocol ListContactsResponse {
    var id: Int { get }
    var name: String? { get }
    var email: String? { get }
    var phone: String? { get }
}

struct ListContactsInteractor: UseCase {
    typealias Input = ListContactsRequest
    typealias Output = [ListContactsResponse]?
    typealias UseCaseError = ListContactsError
    
    var dataStore: ListContactsDataStore?
    
    func process(_ input: Input, withCompletion completion: @escaping (Result<Output, UseCaseError>) -> Void) {
        guard let dataStore = dataStore else { completion(.success(nil)); return }
        DispatchQueue.global(qos: .userInitiated).async {
            dataStore.getContacts(matching: input.searchCriteria) { response in
                DispatchQueue.main.async {
//                    completion(response)                    
                }
            }
        }
    }
}

enum ListContactsError: Error {
    
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
        let name: String?
        let email: String?
        let phone: String?
    }
    
    func getContacts(matching criteria: String?, withCompletion: (Result<[ListContactsDataStoreResponse]?, PersistenceError>) -> Void) {
        
    }
}
