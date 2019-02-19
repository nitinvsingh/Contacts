//
//  DataStore.swift
//  Contacts
//
//  Created by nitin-7926 on 16/02/19.
//  Copyright © 2019 Nitin Singh. All rights reserved.
//

import Foundation
import SQLite3


class SQLDataStore {
    
    //    private let startContactId = 100_000_000
    private static var newId: Int = 100_000_003
    private var database: OpaquePointer? = nil
    var contacts: [Int: Contact]
    
    init(atPath path: String, contacts: [Int: Contact]? = nil) {
        
        // create contact table in the database
        
                guard let contacts = contacts else {
                    self.contacts = [
                        100_000_001 : Contact(id: 100_000_001, firstName: "Nitin", middleName: "Vinod", lastName: "Singh", email: "nitin.singh@zohocorp.com", phone: "9664070510"),
                        100_000_002 : Contact(id: 100_000_002, firstName: "Vinod", middleName: nil, lastName: "Singh", email: nil, phone: "9664069353"),
                        100_000_003 : Contact(id: 100_000_003, firstName: "Pratima", middleName: "Vinod", lastName: "Singh", email: nil, phone: "9869765138")
                    ]
                    return
                }
                self.contacts = contacts
        /*
        let documentDirectory: URL
        do {
            documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        } catch {
            fatalError("URL of DocumentDirectory in UserDomainMask unavailable.")
        }
        let dbPath = documentDirectory.appendingPathComponent(path).relativePath
        let shouldPrepareCreateTables = !FileManager.default.fileExists(atPath: dbPath)
        var db: OpaquePointer? = nil
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            database = db
            if shouldPrepareCreateTables {
                var createContactTableStatement: OpaquePointer? = nil
                let createContactTableQuery = """
                    CREATE TABLE CONTACT(ID INTEGER PRIMARY KEY, FIRSTNAME CHAR(255), MIDDLENAME CHAR(255), LASTNAME CHAR(255), EMAIL CHAR(50), PHONE CHAR(15));
                """
                if sqlite3_prepare(database, createContactTableQuery, -1, &createContactTableStatement, nil) == SQLITE_OK {
                    if sqlite3_step(createContactTableStatement) == SQLITE_DONE {
                        
                    }
                }
            }
        }
        self.contacts = [:]
 */
    }
}

extension SQLDataStore: CreateContactDataStore {
    func createContact(usingDetail data: CreateContactDataStoreRequest, withCompletion completion: (Result<CreateContactDataStoreResponse, PersistenceError>) -> Void) {
        let newDSContact = Contact(id: data.id, firstName: data.firstName, middleName: data.middleName, lastName: data.lastName, email: data.email, phone: data.phone)
        contacts[data.id] = newDSContact
        SQLDataStore.newId = data.id
        completion(.success(newDSContact))
    }
    
    public var newContactId: Int {
        return SQLDataStore.newId + 1
    }
}

extension SQLDataStore: EditContactDataStore {
    func updateDetails(of contact: EditContactDataStoreRequest, withCompletion completion: (Result<EditContactDataStoreResponse, PersistenceError>) -> Void) {
        var contactToBeEdited = contacts[contact.id]
        guard contactToBeEdited != nil else { completion(.failure(.operationFailure)); return }
        contactToBeEdited?.firstName = contact.firstName
        contactToBeEdited?.middleName = contact.middleName
        contactToBeEdited?.lastName = contact.lastName
        contactToBeEdited?.email = contact.email
        contactToBeEdited?.phone = contact.phone
        contacts[contact.id] = contactToBeEdited
        completion(Result.success(contact))
    }
}

extension SQLDataStore: ListContactsDataStore {
    func getContacts(matching criteria: String?, withCompletion completion: @escaping (Result<[ListContactsDataStoreResponse]?, PersistenceError>) -> Void) {
        //        let matchedContacts = contacts.filter { (key: Int, contact: Contact) in
        //            return false
        //        }
        //        if matchedContacts.isEmpty {
        //            completion(.failure(.operationFailure))
        //        }
        var rows = [ListContactsDataStoreResponse]()
        for (_, contact) in contacts {
            rows.append(contact)
        }
        completion(.success(rows))
    }
    
}

extension SQLDataStore: ContactInfoDataStore {
    func getContactInfo(forId id: Int, withCompletion completion: @escaping (Result<ContactInfoResponse, PersistenceError>) -> Void) {
        guard let requestedContact = contacts[id] else {
            completion(.failure(.invalidContactKey))
            return
        }
        completion(.success(requestedContact))
    }
}

extension SQLDataStore: DeleteContactDataStore {
    func deleteContact(havingId id: Int, withCompletion completion: @escaping (Result<DeleteContactDataStoreResponse, PersistenceError>) -> Void) {
        guard let _ = contacts.removeValue(forKey: id) else {
            completion(.failure(.invalidContactKey))
            return
        }
        completion(.success(true))
    }
}
