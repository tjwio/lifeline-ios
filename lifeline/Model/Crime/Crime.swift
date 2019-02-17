//
//  Crime.swift
//  lifeline
//
//  Created by Tim Wong on 2/16/19.
//  Copyright © 2019 tjwio. All rights reserved.
//

import UIKit
import MapKit

enum DangerLevel {
    case ok, warning, danger
    
    var image: UIImage? {
        switch self {
        case .ok: return UIImage(named: "green_ok_symbol")
        case .warning: return UIImage(named: "yellow_warning_symbol")
        case .danger: return UIImage(named: "red_danger_symbol")
        }
    }
}

struct Crime: Codable {
    enum Category: String, Codable {
        case homicide, rape, assault, robbery, burglary, theft
        case aggravatedAssault = "aggravatedassault"
        case grandTheftAuto = "grandtheftauto"
        case theftFromVehicle = "theftfromvehicle"
        
        var color: UIColor {
            switch self {
            case .homicide, .rape: return UIColor.Red.normal
            case .assault, .aggravatedAssault: return UIColor.Red.normal
            case .robbery, .grandTheftAuto: return UIColor.Orange.normal
            case .burglary, .theft, .theftFromVehicle: return UIColor.Yellow.normal
            }
        }
        
        var image: UIImage? {
            switch self {
            case .homicide, .rape: return UIImage(named: "red_hex")
            case .assault, .aggravatedAssault: return UIImage(named: "red_hex")
            case .robbery, .grandTheftAuto: return UIImage(named: "orange_hex")
            case .burglary, .theft, .theftFromVehicle: return UIImage(named: "yellow_hex")
            }
        }
        
        var dangerLevel: DangerLevel {
            switch self {
            case .homicide, .rape, .assault, .aggravatedAssault, .robbery, .grandTheftAuto: return .danger
            default: return .warning
            }
        }
    }
    
    struct Point: Codable {
        var lat: Double
        var lon: Double
        
        enum CodingKeys: String, CodingKey {
            case lat, lon
        }
    }
    
    var title: String
    var description: String
    var category: Category
    var start: Date
    var point: Point
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: point.lat, longitude: point.lon)
    }
    
    enum CodingKeys: String, CodingKey {
        case title, description, start, point
        case category = "slug"
    }
}
