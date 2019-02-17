//
//  School.swift
//  lifeline
//
//  Created by Tim Wong on 2/16/19.
//  Copyright © 2019 tjwio. All rights reserved.
//

import Foundation
import MapKit
import ReactiveCocoa
import ReactiveSwift
import Result

struct School {
    enum Category: CaseIterable {
        case usc, ucla, csula, csun
        
        var name: String {
            switch self {
            case .usc: return "USC"
            case .ucla: return "UCLA"
            case .csula: return "Cal State LA"
            case .csun: return "Cal State Northridge"
            }
        }
        
        var neighbourhoods: [String] {
            switch self {
            case .usc: return ["university-park", "exposition-park", "adams-normandie", "historic-south-central"]
            case .ucla: return ["westwood", "west-los-angeles", "century-city", "brentwood", "sawtelle"]
            case .csula: return ["east-los-angeles", "el-sereno", "alhambra", "monterey-park"]
            case .csun: return ["northridge", "reseda", "lake-balboa", "north-hills"]
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
    
    var category: Category
    var crimes: MutableProperty<[Crime]>
    var dangerLevel: Property<DangerLevel>
    
    init(category: Category) {
        self.category = category
        self.crimes = MutableProperty([])
        self.dangerLevel = self.crimes.map { crimes in
            let count =  crimes.filter { $0.category == .homicide || $0.category == .rape || $0.category == .assault }.count
            
            if count >= 10 {
                return .danger
            } else if count >= 3 {
                return .warning
            } else {
                return .ok
            }
        }
    }
    
    func loadCrimes() -> [SignalProducer<[Crime], AnyError>] {
        return category.neighbourhoods.map { self.loadCrimes(neighbourhood: $0) }
    }
    
    private func loadCrimes(neighbourhood: String) -> SignalProducer<[Crime], AnyError> {
        return SignalProducer { (observer, _) in
            NetworkManager.shared.loadCrimeStats(neighbourhood: neighbourhood, startDate: Calendar.current.date(byAdding: .month, value: -1, to: Date())!, endDate: Date(), success: { crimes in
                self.crimes.value.append(contentsOf: crimes)
                observer.sendCompleted()
            }, failure: { error in
                observer.send(error: AnyError(error))
            })
        }
    }
}

class SchoolHolder: NSObject {
    static let shared = SchoolHolder()
    
    var schools: [School]
    
    private var disposables = CompositeDisposable()
    
    private override init() {
        schools = [
            School(category: .usc),
            School(category: .ucla),
            School(category: .csula),
            School(category: .csun)
        ]
    }
    
    deinit {
        disposables.dispose()
    }
    
    func loadSchoolCrimes(success: SchoolListHandler?, failure: ErrorHandler?) {
        let producers = schools.flatMap { $0.loadCrimes() }
        
        disposables += SignalProducer.combineLatest(producers).start { [unowned self] action in
            switch action.event {
            case .completed: success?(self.schools)
            case .failed(let error): failure?(error)
            default: failure?(CommonError.nilOrEmpty)
            }
        }
    }
}
