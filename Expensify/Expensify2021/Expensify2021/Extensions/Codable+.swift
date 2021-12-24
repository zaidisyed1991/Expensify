//
//  Codable+.swift
//  Expensify2021
//
//  Created by Syed on 27/11/2021.
//

import Foundation

extension Encodable {
    var jsonObject: Any? {
        try? JSONEncoder().encode(self)
    }
}
