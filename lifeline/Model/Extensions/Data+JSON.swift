//
//  Data+JSON.swift
//  lifeline
//
//  Created by Tim Wong on 2/16/19.
//  Copyright © 2019 tjwio. All rights reserved.
//

import Foundation

extension Data {
    public func decodeJson<T>(_ type: T.Type) -> T? where T: Decodable {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        if let response = try? JSONDecoder().decode(type, from: self) {
            return response
        }
        
        return nil
    }
}
