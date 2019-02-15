//
//  UseCase.swift
//  Contacts
//
//  Created by nitin-7926 on 14/02/19.
//  Copyright © 2019 Nitin Singh. All rights reserved.
//

import Foundation

enum Result<Success, Failure: Swift.Error> {
    case success(Success)
    case failure(Failure)
    
    func get() throws -> Success {
        switch self {
        case .success(let value):
            return value
        case .failure(let err):
            throw err
        }
    }
}

protocol UseCase {
    associatedtype Input
    associatedtype Output
    associatedtype UseCaseError: Swift.Error
    func process(_ input: Input, withCompletion completion: (Result<Output, UseCaseError>) -> Void)
}
protocol Presenter {
    associatedtype Input
    associatedtype Output
    associatedtype PresenterError: Swift.Error
    mutating func generateViewModel(from input: Input) -> Result<Output, PresenterError>
}


