//
//  NetworkManager+CrimeData.swift
//  lifeline
//
//  Created by Tim Wong on 2/16/19.
//  Copyright © 2019 tjwio. All rights reserved.
//

import Foundation
import Alamofire
import JavaScriptCore

extension NetworkManager {
    private struct Constants {
        static let hood = "hood"
        static let startDate = "start_date"
        static let endDate = "end_date"
        static let callback = "callback"
        
        static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            return formatter
        }()
    }
    
    struct Helper {
        static func getValidJsonData(for data: Data) -> [JSON]? {
            guard var str = String(data: data, encoding: .utf8) else { return nil }
            str.removeSubrange(str.index(str.endIndex, offsetBy: -3) ..< str.endIndex)
            str.removeSubrange(str.startIndex ... str.index(after: str.startIndex))
            
            let jsSource = "var obj = function(str) { return eval('(' + str + ')'); }"
            let context = JSContext()
            context?.evaluateScript(jsSource)
            let objFunc = context?.objectForKeyedSubscript("obj")
            let arr = objFunc?.call(withArguments: ["\(str)"])?.toArray() as? [JSON]
            
            return arr
        }
    }
    
    func loadCrimeStats(neighbourhood: String, startDate: Date, endDate: Date, success: CrimeListHandler?, failure: ErrorHandler?) {
        AF.request("https://maps.latimes.com/crime/neighborhood/json/", method: .get, parameters: [
            Constants.hood: neighbourhood,
            Constants.startDate: Constants.dateFormatter.string(from: startDate),
            Constants.endDate: Constants.dateFormatter.string(from: endDate),
            Constants.callback: "_"]).printCURL().responseData { response in
                switch response.result {
                case .success:
                    guard let raw = response.result.value, let jsonList = Helper.getValidJsonData(for: raw) else {
                        failure?(CommonError.invalidJson)
                        return
                    }
                    
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        let crimeList = try decoder.decode([Crime].self, from: jsonList)
                        success?(crimeList)
                    } catch let error {
                        failure?(error)
                    }
                case .failure(let error): failure?(error)
                }
        }
    }
}
