//
//  AppConstants.swift
//  lifeline
//
//  Created by Tim Wong on 2/16/19.
//  Copyright © 2019 tjwio. All rights reserved.
//

import Foundation

typealias JSON = [String: Any]

typealias CrimeHandler = (Crime) -> Void
typealias CrimeListHandler = ([Crime]) -> Void

typealias SchoolHandler = (School) -> Void
typealias SchoolListHandler = ([School]) -> Void

typealias ErrorHandler = (Error) -> Void

enum CommonError: Error {
    case imageData
    case invalidJson
    case nilOrEmpty
    
    var localizedDescription: String {
        switch self {
        case .imageData:
            return "Failed to encode image data"
        case .invalidJson:
            return "Invalid JSON Response"
        case .nilOrEmpty:
            return "Response was nil or empty"
        }
    }
}
