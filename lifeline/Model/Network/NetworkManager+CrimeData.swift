//
//  NetworkManager+CrimeData.swift
//  lifeline
//
//  Created by Tim Wong on 2/16/19.
//  Copyright © 2019 tjwio. All rights reserved.
//

import Foundation
import Alamofire

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
        static func getValidJsonData(for data: Data) -> Data? {
            guard var str = String(data: data, encoding: .utf8) else { return nil }
            str.removeSubrange(str.index(before: str.endIndex) ... str.endIndex)
            str.removeSubrange(str.startIndex ... str.index(after: str.startIndex))
            return str.data(using: .utf8)
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
                    guard let raw = response.result.value, let data = Helper.getValidJsonData(for: raw), let crimeList = data.decodeJson([Crime].self) else {
                        failure?(CommonError.invalidJson)
                        return
                    }
                    
                    success?(crimeList)
                case .failure(let error): failure?(error)
                }
        }
    }
}
