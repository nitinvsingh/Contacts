//
//  ListContactsPresenter.swift
//  Contacts
//
//  Created by nitin-7926 on 18/02/19.
//  Copyright © 2019 Nitin Singh. All rights reserved.
//

import Foundation

struct ListContactsPresenter: Presenter {
    struct ViewModel {
        let id: Int
        let name: String
    }
    
    typealias Input = [ContactResponse]
    typealias Output = [ViewModel]
    
    
    func generateViewModel(from input: Input) -> Output {
        return input.map { ViewModel(id: $0.id, name: $0.displayName) }
    }
}
