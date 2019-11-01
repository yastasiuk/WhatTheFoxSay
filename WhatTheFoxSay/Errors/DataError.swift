//
//  AnimalsErrors.swift
//  WhatTheFoxSay
//
//  Created by Stasiuk Yaroslav on 27.10.2019.
//  Copyright © 2019 Stasiuk Yaroslav. All rights reserved.
//

import Foundation

extension DataError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .connection:
            return NSLocalizedString(
                "Connection error",
                comment: ""
            )
        case .parse:
            return NSLocalizedString(
                "Unable to parse",
                comment: ""
            )
        }
    }
}

enum DataError: Error {
    case connection
    case parse
}
