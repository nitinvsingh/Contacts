//
//  CreateContactPresenter.swift
//  Contacts
//
//  Created by nitin-7926 on 18/02/19.
//  Copyright © 2019 Nitin Singh. All rights reserved.
//

import Foundation

struct CreateEditContactPresenter: Presenter {
    
    typealias ViewModel = Contact
    typealias Input = ContactResponse
    typealias Output = ViewModel
    
    func generateViewModel(from input: Input) -> Output {
        return ViewModel(id: input.id, firstName: input.firstName, middleName: input.middleName, lastName: input.lastName, email: input.email, phone: input.phone)
    }
}
