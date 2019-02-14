//
//  OptionalType.swift
//  Contacts
//
//  Created by nitin-7926 on 14/02/19.
//  Copyright © 2019 Nitin Singh. All rights reserved.
//

import Foundation

protocol OptionalProtocol {
    associatedtype Wrapped
    var optional: Wrapped? { get }
}

extension Optional: OptionalProtocol {
    var optional: Wrapped? { return self }
}
