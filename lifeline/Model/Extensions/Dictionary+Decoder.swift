//
//  Dictionary+Decoder.swift
//  lifeline
//
//  Created by Tim Wong on 2/16/19.
//  Copyright © 2019 tjwio. All rights reserved.
//

import Foundation

extension JSONDecoder {
    open func decode<T>(_ type: T.Type, from json: Any) throws -> T where T: Decodable {
        let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        return try self.decode(type, from: data)
    }
}

extension Dictionary where Key == String {
    public func decodeJson<T>(_ type: T.Type) -> T? where T: Decodable {
        if let response = try? JSONDecoder().decode(type, from: self) {
            return response
        }
        return nil
    }
}

extension Array where Element == [String: Any] {
    public func decodeJsonList<T>(_ type: T.Type) -> [T]? where T: Decodable {
        if let response = try? JSONDecoder().decode([T].self, from: self) {
            return response
        }
        
        return nil
    }
}
