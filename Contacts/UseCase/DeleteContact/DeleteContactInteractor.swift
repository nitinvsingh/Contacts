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

typealias DeleteContactResponse = Bool

struct DeleteContactInteractor: UseCase {
    typealias Input = DeleteContactRequest
    typealias Output = DeleteContactResponse
    typealias UseCaseError = ContactError
    
    var dataStore: DeleteContactDataStore?
    
    func process(_ input: Input, withCompletion completion: @escaping (Result<Output, UseCaseError>) -> Void) {
        guard let dataStore = dataStore else {
            completion(.success(true))
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            dataStore.deleteContact(havingId: input.id, withCompletion: { response in
                DispatchQueue.main.async {
                    switch response {
                    case .success: completion(.success(true))
                    case .failure(let reason): completion(.failure(.persistenceFailure(reason)))
                    }
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
