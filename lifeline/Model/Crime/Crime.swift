//
//  Crime.swift
//  lifeline
//
//  Created by Tim Wong on 2/16/19.
//  Copyright © 2019 tjwio. All rights reserved.
//

import Foundation
import MapKit

enum Student {
    case usc, ucla, csula, csun
    
    var name: String {
        switch self {
        case .usc: return "USC"
        case .ucla: return "UCLA"
        case .csula: return "Cal State LA"
        case .csun: return "Cal State Northridge"
        }
    }
    
    var neighbourhood: String {
        switch self {
        case .usc: return "university-park"
        case .ucla: return "westwood"
        case .csula: return "el-sereno"
        case .csun: return "northridge"
        }
    }
    
    var coordinate: CLLocationCoordinate2D {
        switch self {
        case .usc: return CLLocationCoordinate2D(latitude: 34.02394, longitude: -118.28553)
        case .ucla: return CLLocationCoordinate2D(latitude: 34.07, longitude: -118.44)
        case .csula: return CLLocationCoordinate2D(latitude: 34.062769, longitude: -118.17092)
        case .csun: return CLLocationCoordinate2D(latitude: 34.23565, longitude: -118.52783)
        }
    }
}
