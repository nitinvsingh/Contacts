//
//  DeleteContactInteractor.swift
//  Contacts
//
//  Created by nitin-7926 on 16/02/19.
//  Copyright © 2019 Nitin Singh. All rights reserved.
//

import Foundation

protocol DeleteContactRequest {
    var id: Int { get }
}

protocol DeleteContactResponse {
    var deleted: Bool { get }
}

struct DeleteContactInteractor: UseCase {
    typealias Input = DeleteContactRequest
    typealias Output = DeleteContactResponse
    typealias UseCaseError = DeleteContactError
    
    var dataStore: DeleteContactDataStore?
    
    func process(_ input: Input, withCompletion completion: @escaping (Result<Output, UseCaseError>) -> Void) {
        guard let dataStore = dataStore else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            dataStore.deleteContact(havingId: input.id, withCompletion: { response in
                DispatchQueue.main.async {
                    // completion(response)
                }
            })
        }
    }
}

// MARK: DataStore Boundary
typealias DeleteContactDataStoreResponse = DeleteContactResponse
protocol DeleteContactDataStore {
    func deleteContact(havingId id: Int, withCompletion completion: @escaping (Result<DeleteContactDataStoreResponse, PersistenceError>) -> Void)
}

enum DeleteContactError: Error {
    
    var localizedDescription: String { return "Failed to delete contact" }
}
