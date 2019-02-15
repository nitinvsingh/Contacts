//
//  Contact.swift
//  Contacts
//
//  Created by nitin-7926 on 14/02/19.
//  Copyright © 2019 Nitin Singh. All rights reserved.
//

import Foundation

struct Contact {
    let id: Int
    var firstName: String?
    var middleName: String?
    var lastName: String?
    var email: String?
    var phone: String?
    
    var fullName: String? {
        let _fullName = [firstName, middleName, lastName].unwrapRemovingNil().concat(byAppending: " ")
        return _fullName.isEmpty ? nil : _fullName
    }
    
    init(id: Int, firstName: String?, middleName: String?, lastName: String?, email: String?, phone: String?) {
        self.id = id
        self.firstName = firstName
        self.middleName = middleName
        self.lastName = lastName
        self.email = email
        self.phone = phone
    }
}
