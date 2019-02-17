//
//  Result.swift
//  Contacts
//
//  Created by Nitin Singh on 17/02/19.
//  Copyright © 2019 Nitin Singh. All rights reserved.
//

import Foundation

public enum Result<Success, Failure: Swift.Error> {
    case success(Success)
    case failure(Failure)
    
    public func get() throws -> Success {
        switch self {
        case .success(let wrappedValue):
            return wrappedValue
        case .failure(let err):
            throw err
        }
    }
}
