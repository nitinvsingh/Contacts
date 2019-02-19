//
//  ContactError.swift
//  Contacts
//
//  Created by nitin-7926 on 18/02/19.
//  Copyright © 2019 Nitin Singh. All rights reserved.
//

import Foundation

public enum ContactError: Error {
    case initializationFailure(ContactErrorReason)
    case updateFailure(ContactErrorReason)
    case persistenceUnavailble
    case persistenceFailure(PersistenceError)
    case invalidRequest(ContactErrorReason)
    
    
    public enum ContactErrorReason {
        case noData
        case invalidContactId
        case invalidFieldData(fieldName: String)
    }
}

public enum PersistenceError: Error {
    case persistenceUnavailable
    case operationFailure(dbError: String?)
    case invalidContactKey
    case prepareQueryFailure(dbError: String?)
    case queryExecutionFailure(dbError: String?)
}

