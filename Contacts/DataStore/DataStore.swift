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
    
    private static var lastId: Int = 100_000
    private var database: OpaquePointer? = nil
    
    init(atPath path: String, contacts: [Int: Contact]? = nil) {
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
                    sqlite3_step(createContactTableStatement)
                }
                sqlite3_finalize(createContactTableStatement)
                let lastContactIdStoreQuery = "CREATE TABLE LASTCONTACTID(LASTID INTEGER);"
                var lastContactIdStoreStatement: OpaquePointer? = nil
                if sqlite3_prepare(database, lastContactIdStoreQuery, -1, &lastContactIdStoreStatement, nil) == SQLITE_OK {
                    sqlite3_step(lastContactIdStoreStatement)
                }
                sqlite3_finalize(lastContactIdStoreStatement)
                
                let lastContactIdQuery = "INSERT INTO LASTCONTACTID VALUES(?);"
                var lastContactStatement: OpaquePointer? = nil
                if sqlite3_prepare(database, lastContactIdQuery, -1, &lastContactStatement, nil) == SQLITE_OK {
                    sqlite3_bind_int(lastContactStatement, 1, 100_000_000.dbInt)
                    sqlite3_step(lastContactStatement)
                }
                sqlite3_finalize(lastContactStatement)
            }
            let lastIdQuery = "SELECT * FROM LASTCONTACTID"
            var lastIdStatement: OpaquePointer? = nil
            if sqlite3_prepare(database, lastIdQuery, -1, &lastIdStatement, nil) == SQLITE_OK {
                if sqlite3_step(lastIdStatement) == SQLITE_ROW {
                    SQLDataStore.lastId = Int(sqlite3_column_int(lastIdStatement, 0))
                }
            }
            sqlite3_finalize(lastIdStatement)
        }
    }
    
    deinit {
        if database != nil {
            sqlite3_close(database)
        }
    }
}

extension SQLDataStore {
    var errorMessage: String {
        return String(cString: sqlite3_errmsg(database))
    }
}

extension SQLDataStore: CreateContactDataStore {
    func createContact(usingDetail data: CreateContactDataStoreRequest, withCompletion completion: (Result<CreateContactDataStoreResponse, PersistenceError>) -> Void) {
        let insertQuery = """
            INSERT INTO CONTACT VALUES(?, ?, ?, ?, ?, ?);
        """
        var insertStatement: OpaquePointer? = nil
        guard sqlite3_prepare(database, insertQuery, -1, &insertStatement, nil) == SQLITE_OK else {
            completion(.failure(.prepareQueryFailure(dbError: errorMessage)))
            return
        }
        defer {
            sqlite3_finalize(insertStatement)
        }
        sqlite3_bind_int(insertStatement, 1, data.id.dbInt)
        for (index, element) in [data.firstName, data.middleName, data.lastName, data.email, data.phone].enumerated() {
            let dataIndex = index + 2
            let _ = element != nil ? sqlite3_bind_text(insertStatement, dataIndex.dbInt, element!.dbString, -1, nil) : sqlite3_bind_null(insertStatement, dataIndex.dbInt)
        }
        
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            completion(.failure(.queryExecutionFailure(dbError: errorMessage)))
            return
        }
        SQLDataStore.lastId += 1
        let updateLastIdQuery = "UPDATE LASTCONTACTID SET LASTID = ?;"
        var updateLastIdStatement: OpaquePointer? = nil
        guard sqlite3_prepare(database, updateLastIdQuery, -1, &updateLastIdStatement, nil) == SQLITE_OK else {
            completion(.failure(.prepareQueryFailure(dbError: errorMessage)))
            return
        }
        defer {
            sqlite3_finalize(updateLastIdStatement)
        }
        sqlite3_bind_int(updateLastIdStatement, 1, data.id.dbInt)
        sqlite3_step(updateLastIdStatement)
        completion(.success(data))
    }
    
    public var newContactId: Int {
        return SQLDataStore.lastId + 1
    }
}

extension SQLDataStore: EditContactDataStore {
    func updateDetails(of contact: EditContactDataStoreRequest, withCompletion completion: (Result<EditContactDataStoreResponse, PersistenceError>) -> Void) {
        let updateQuery = "UPDATE CONTACT SET FIRSTNAME = ?, MIDDLENAME = ?, LASTNAME = ?, EMAIL = ?, PHONE = ? WHERE ID = ?;"
        var statement: OpaquePointer? = nil
        defer {
            sqlite3_finalize(statement)
        }
        guard sqlite3_prepare(database, updateQuery, -1, &statement, nil) == SQLITE_OK else { return }
        sqlite3_bind_int(statement, 6, contact.id.dbInt)
        for (index, element) in [contact.firstName, contact.middleName, contact.lastName, contact.email, contact.phone].enumerated() {
            let dataIndex = index + 1
            let _ = element != nil ? sqlite3_bind_text(statement, dataIndex.dbInt, element!.dbString, -1, nil) : sqlite3_bind_null(statement, dataIndex.dbInt)
        }
        guard sqlite3_step(statement) == SQLITE_DONE else { return }
        completion(.success(contact))
    }
}

extension SQLDataStore: ListContactsDataStore {
    func getContacts(matching criteria: String?, withCompletion completion: @escaping (Result<[ListContactsDataStoreResponse], PersistenceError>) -> Void) {
        var selectQuery = "SELECT * FROM CONTACT"
        if let criteria = criteria {
            let wildSearchCriteria = "%\(criteria)%"
            let conditionString = "WHERE FIRSTNAME LIKE '\(wildSearchCriteria)' || MIDDLENAME LIKE '\(wildSearchCriteria)' || LASTNAME LIKE '\(wildSearchCriteria)' || EMAIL LIKE '\(wildSearchCriteria)' || PHONE LIKE '\(wildSearchCriteria)'"
            selectQuery += " " + conditionString
        }
        selectQuery += ";"
        var selectStatement: OpaquePointer? = nil
        guard sqlite3_prepare(database, selectQuery, -1, &selectStatement, nil) == SQLITE_OK else {
            return
        }
        var searchedContacts = [ListContactsDataStoreResponse]()
        while sqlite3_step(selectStatement) == SQLITE_ROW {
            let id = Int(sqlite3_column_int(selectStatement, 0))
            let text = [
                    sqlite3_column_text(selectStatement, 1),
                    sqlite3_column_text(selectStatement, 2),
                    sqlite3_column_text(selectStatement, 3),
                    sqlite3_column_text(selectStatement, 4),
                    sqlite3_column_text(selectStatement, 5)
                ].map { (item) -> String? in
                    guard let item = item else { return nil }
                    return String(cString: item)
            }
            searchedContacts.append(Contact(id: id, firstName: text[0], middleName: text[1], lastName: text[2], email: text[3], phone: text[4]))
        }
        completion(.success(searchedContacts))
    }
}

extension SQLDataStore: ContactInfoDataStore {
    func getContactInfo(forId id: Int, withCompletion completion: @escaping (Result<ContactInfoResponse, PersistenceError>) -> Void) {
        let selectDetailQuery = "SELECT * FROM CONTACT WHERE ID = ?;"
        var selectDetailStatement: OpaquePointer? = nil
        guard sqlite3_prepare(database, selectDetailQuery, -1, &selectDetailStatement, nil) == SQLITE_OK else {
            return
        }
        guard sqlite3_bind_int(selectDetailStatement, 1, id.dbInt) == SQLITE_OK else {
            return
        }
        
        guard sqlite3_step(selectDetailStatement) == SQLITE_ROW else {
            return
        }
        let id = Int(sqlite3_column_int(selectDetailStatement, 0))
        let text = [
            sqlite3_column_text(selectDetailStatement, 1),
            sqlite3_column_text(selectDetailStatement, 2),
            sqlite3_column_text(selectDetailStatement, 3),
            sqlite3_column_text(selectDetailStatement, 4),
            sqlite3_column_text(selectDetailStatement, 5)
            ].map { (item) -> String? in
                guard let item = item else { return nil }
                return String(cString: item)
        }
        completion(.success(Contact(id: id, firstName: text[0], middleName: text[1], lastName: text[2], email: text[3], phone: text[4])))
    }
}

extension SQLDataStore: DeleteContactDataStore {
    func deleteContact(havingId id: Int, withCompletion completion: @escaping (Result<DeleteContactDataStoreResponse, PersistenceError>) -> Void) {
        let deleteQuery = "DELETE FROM CONTACT WHERE ID = ?"
        var statement: OpaquePointer? = nil
        guard sqlite3_prepare(database, deleteQuery, -1, &statement, nil) == SQLITE_OK else {
            return
        }
        
        guard sqlite3_bind_int(statement, 1, id.dbInt) == SQLITE_OK else { return }
        
        guard sqlite3_step(statement) == SQLITE_DONE else { return }
        
        completion(.success(true))
    }
}
