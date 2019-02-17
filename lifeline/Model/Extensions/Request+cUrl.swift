//
//  Request+cUrl.swift
//  lifeline
//
//  Created by Tim Wong on 2/16/19.
//  Copyright © 2019 tjwio. All rights reserved.
//

import Alamofire

extension Request {
    public var cURL: String {
        return request?.cURL ?? ""
    }
    
    public func printCURL() -> Self {
        print("\(cURL)")
        
        return self
    }
}

extension URLRequest {
    /// Returns a cURL command for a request
    /// - return A String object that contains cURL command or "" if an URL is not properly initalized.
    public var cURL: String {
        guard
            let url = url,
            let httpMethod = httpMethod,
            url.absoluteString.utf8.count > 0
            else { return "" }
        
        var curlCommand = "curl \\\n"
        
        // URL
        curlCommand = curlCommand.appendingFormat(" '%@' ", url.absoluteString)
        
        // Method if different from GET
        if httpMethod != "GET" {
            curlCommand = curlCommand.appendingFormat("\\\n -X %@ ", httpMethod)
        }
        
        // Headers
        let allHeadersFields = allHTTPHeaderFields!
        let allHeadersKeys = Array(allHeadersFields.keys)
        let sortedHeadersKeys  = allHeadersKeys.sorted(by: <)
        for key in sortedHeadersKeys {
            curlCommand = curlCommand.appendingFormat("\\\n -H '%@: %@' ", key, self.value(forHTTPHeaderField: key)!)
        }
        
        // HTTP body
        if let httpBody = httpBody, httpBody.count > 0 {
            let httpBodyString = String(data: httpBody, encoding: String.Encoding.utf8)!
            let escapedHttpBody = URLRequest.escapeAllSingleQuotes(httpBodyString)
            curlCommand = curlCommand.appendingFormat("\\\n --data '%@' \n", escapedHttpBody)
        }
        
        return curlCommand
    }
    
    
    /// Escapes all single quotes for shell from a given string.
    ///
    /// - Parameter value: string to escape
    /// - Returns: string with quotes escaped
    static func escapeAllSingleQuotes(_ value: String) -> String {
        return value.replacingOccurrences(of: "'", with: "'\\''")
    }
}
