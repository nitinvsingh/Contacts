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
    associatedtype UseCaseError: Swift.Error
    func process(_ input: Input, withCompletion completion: @escaping (Result<Output, UseCaseError>) -> Void)
}
protocol Presenter {
    associatedtype Input
    associatedtype Output
    mutating func generateViewModel(from input: Input) -> Output
}


