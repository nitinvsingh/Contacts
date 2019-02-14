//
//  Extension+Sequence.swift
//  Contacts
//
//  Created by nitin-7926 on 14/02/19.
//  Copyright © 2019 Nitin Singh. All rights reserved.
//

import Foundation

extension Sequence where Element == String {
    func concat(byAppending spacer: Element) -> Element {
        return self.reduce("") { result, item in
            guard item.isEmpty == false else { return result }
            guard result.isEmpty == false else { return item }
            return result + spacer + item
        }
    }
}

extension Sequence where Element: OptionalProtocol {
    func unwrapRemovingNil() -> [Element.Wrapped] {
        var unwrappedElements = [Element.Wrapped]()
        for element in self {
            if let wrapped = element.optional {
                unwrappedElements.append(wrapped)
            }
        }
        return unwrappedElements
    }
}
