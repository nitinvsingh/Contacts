//
//  Extension+String+Int.swift
//  Contacts
//
//  Created by nitin-7926 on 19/02/19.
//  Copyright © 2019 Nitin Singh. All rights reserved.
//

import Foundation

extension String {
    var dbString: UnsafePointer<Int8>? {
        return (self as NSString).utf8String
    }
}

extension Int {
    var dbInt: Int32 {
        return Int32(self)
    }
}
