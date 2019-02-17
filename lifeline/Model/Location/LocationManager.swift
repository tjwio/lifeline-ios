//
//  LocationManager.swift
//  lifeline
//
//  Created by Tim Wong on 2/16/19.
//  Copyright © 2019 tjwio. All rights reserved.
//

import MapKit
import ArcGIS

class LocationManager: AGSLocationDataSource, CLLocationManagerDelegate {
    var updateCallback: ((CLLocation) -> Void)?
    let locationManager = CLLocationManager()
    
    var isAuthorized: Bool {
        return CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways
    }
    
    init(updateCallback: ((CLLocation) -> Void)? = nil) {
        self.updateCallback = updateCallback
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.delegate = self
    }
    
    override func doStart() {
        if isAuthorized {
            locationManager.startUpdatingLocation()
            didStartOrFailWithError(nil)
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    override func doStop() {
        locationManager.stopUpdatingLocation()
        didStop()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            didStartOrFailWithError(nil)
        } else {
            didStartOrFailWithError(CommonError.nilOrEmpty)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location {
            self.didUpdate(AGSLocation(clLocation: location))
        }
    }
}
