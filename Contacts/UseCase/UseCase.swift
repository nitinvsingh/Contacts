//
//  UseCase.swift
//  Contacts
//
//  Created by nitin-7926 on 14/02/19.
//  Copyright © 2019 Nitin Singh. All rights reserved.
//

import Foundation

protocol UseCase {
    associatedtype Input
    associatedtype Output
    func process(_ input: Input, withCompletion completion: (Output) -> Void)
}

protocol Presenter {
    associatedtype Input
    associatedtype Output
    func generateViewModel(from input: Input) -> Output 
}
