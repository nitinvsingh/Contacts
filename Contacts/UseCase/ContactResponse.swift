//
//  ContactResponse.swift
//  Contacts
//
//  Created by Nitin Singh on 17/02/19.
//  Copyright © 2019 Nitin Singh. All rights reserved.
//

import Foundation

public protocol ContactResponse {
    var id: Int { get }
    var firstName: String? { get }
    var middleName: String? { get }
    var lastName: String? { get }
    var email: String? { get }
    var phone: String? { get }
}


extension Contact: ContactResponse {}

extension ContactResponse {
    var displayName: String  {
        let name = [firstName, middleName, lastName].unwrapRemovingNil().concat(byAppending: " ")
        var displayName = name.isEmpty ? email ?? "" : name
        displayName = displayName.isEmpty ? phone ?? "No Name" : displayName
        return displayName
    }
    
    private var nonFirstEmailChars: [String] {
        return ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "_"]
    }
    
    func validateEmailPhone() -> Result<Bool, ContactError> {
        if let email = email, email.isEmpty == false, let firstChar = email.first {
            guard nonFirstEmailChars.firstIndex(of: String(firstChar)) == nil, email.contains("@")  else {
                
                return Result.failure(ContactError.invalidRequest(.invalidFieldData(fieldName: "email")))
            }
        }
    
        if let phone = phone, phone.isEmpty == false, phone.count < 8 {
            return Result.failure(ContactError.invalidRequest(.invalidFieldData(fieldName: "phone")))
        }
        
        return .success(true)
    }
}
