//
//  DeleteContactInteractor.swift
//  Contacts
//
//  Created by nitin-7926 on 16/02/19.
//  Copyright © 2019 Nitin Singh. All rights reserved.
//

import Foundation


typealias DeleteContactResponse = Bool

struct DeleteContactInteractor: UseCase {
    var dataStore: DeleteContactDataStore?
    
    func process(_ input: ContactId, withCompletion completion: @escaping (Result<DeleteContactResponse, ContactError>) -> Void) {
        guard let dataStore = dataStore else {
            completion(.success(true))
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            dataStore.deleteContact(havingId: input, withCompletion: { response in
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
typealias DeleteContactDataStoreResponse = Bool

protocol DeleteContactDataStore {
    func deleteContact(havingId id: ContactId, withCompletion completion: @escaping (Result<DeleteContactDataStoreResponse, PersistenceError>) -> Void)
}
