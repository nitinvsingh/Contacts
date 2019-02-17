//
//  EditContactError.swift
//  Contacts
//
//  Created by Nitin Singh on 17/02/19.
//  Copyright © 2019 Nitin Singh. All rights reserved.
//

import Foundation

enum EditContactError: Error {
    case invalidFieldData(fieldName: String)
    
    var localizedDescription: String {
        return "Error occurred while editing contact"
    }
}
