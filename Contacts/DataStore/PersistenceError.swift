//
//  PersistenceError.swift
//  Contacts
//
//  Created by nitin-7926 on 16/02/19.
//  Copyright © 2019 Nitin Singh. All rights reserved.
//

import Foundation


public enum PersistenceError: Error {
    case operationFailure
    case persistenceUnavailable
    
    
    
    var localizedDescription: String { return "Persistence failed to fulfil the request" }
}
