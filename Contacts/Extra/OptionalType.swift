//
//  OptionalType.swift
//  Contacts
//
//  Created by nitin-7926 on 14/02/19.
//  Copyright © 2019 Nitin Singh. All rights reserved.
//

import Foundation

public protocol OptionalProtocol {
    associatedtype Wrapped
    var optional: Wrapped? { get }
}

extension Optional: OptionalProtocol {
    public var optional: Wrapped? { return self }
}
