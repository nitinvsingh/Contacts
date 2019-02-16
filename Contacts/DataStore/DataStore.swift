//
//  DataStore.swift
//  Contacts
//
//  Created by nitin-7926 on 16/02/19.
//  Copyright © 2019 Nitin Singh. All rights reserved.
//

import Foundation

class DataStore {
    
    private let startContactId = 100_000_000
    
    var contacts: [Int: Contact]
    
    init(contacts: [Int: Contact]? = nil) {
        guard let contacts = contacts else {
            self.contacts = [
                100_000_001 : Contact(id: 100_000_001, firstName: "Nitin", middleName: "Vinod", lastName: "Singh", email: "nitin.singh@zohocorp.com", phone: "9664070510"),
                100_000_002 : Contact(id: 100_000_002, firstName: "Vinod", middleName: nil, lastName: "Singh", email: nil, phone: "9664069353"),
                100_000_003 : Contact(id: 100_000_003, firstName: "Pratima", middleName: "Vinod", lastName: "Singh", email: nil, phone: "9869765138")
            ]
            return
        }
        self.contacts = contacts
    }
}

extension DataStore: CreateContactDataStore {
    func createContact(usingDetail data: CreateContactDataStoreRequest, withCompletion completion: (Result<CreateContactDataStoreResponse, PersistenceError>) -> Void) {
        let newDSContact = Contact(id: data.id, firstName: data.firstName, middleName: data.middleName, lastName: data.lastName, email: data.email, phone: data.phone)
        contacts[data.id] = newDSContact
        completion(.success(newDSContact))
    }
    
    public var newContactId: Int {
        return startContactId + contacts.count + 1
    }
}

extension DataStore: EditContactDataStore {
    func updateDetails(of contact: EditContactDataStoreRequest, withCompletion completion: (Result<EditContactDataStoreResponse, PersistenceError>) -> Void) {
        var contactToBeEdited = contacts[contact.id]
        guard contactToBeEdited != nil else { completion(.failure(.operationFailure)); return }
        contactToBeEdited?.firstName = contact.firstName
        contactToBeEdited?.middleName = contact.middleName
        contactToBeEdited?.lastName = contact.lastName
        contactToBeEdited?.email = contact.email
        contactToBeEdited?.phone = contact.phone
        completion(Result.success(true))
    }
}
