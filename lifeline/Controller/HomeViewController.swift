//
//  HomeViewController.swift
//  lifeline
//
//  Created by Tim Wong on 2/16/19.
//  Copyright © 2019 tjwio. All rights reserved.
//

import UIKit
import MapKit
import ArcGIS
import SnapKit

class HomeViewController: UIViewController, SchoolDropdownViewDelegate, AGSGeoViewTouchDelegate {
    
    private struct Constants {
        static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, h:mm a"
            formatter.timeZone = .current
            
            return formatter
        }()
    }
    
    let mapView: AGSMapView = {
        let map = AGSMap(basemap: .streetsNightVector())
        map.initialViewpoint = AGSViewpoint(center: AGSPoint(clLocationCoordinate2D: School.Category.usc.coordinate), scale: 1.5e4)
        
        let mapView = AGSMapView()
        mapView.map = map
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        return mapView
    }()
    
    let schoolDropdown: SchoolDropdownView = {
        let dropdown = SchoolDropdownView()
        dropdown.selectedItem = SchoolHolder.shared.schools.first?.category.name
        dropdown.items = SchoolHolder.shared.schools.map { $0.category.name }
        dropdown.layer.cornerRadius = 10.0
        dropdown.clipsToBounds = true
        dropdown.translatesAutoresizingMaskIntoConstraints = false
        
        return dropdown
    }()
    
    var selectedSchool: School? = SchoolHolder.shared.schools.first {
        didSet {
            guard let school = selectedSchool else { return }
            mapView.setViewpoint(AGSViewpoint(center: AGSPoint(clLocationCoordinate2D: school.category.coordinate), scale: 1.5e4))
        }
    }
    
    private var currentPopupView: CrimeInfoPopupView?
    private var popupFrame: CGRect?
    private var locationManager: LocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = LocationManager(updateCallback: { [weak self] location in
            self?.updateDangerStatus(location: location)
        })
        
        mapView.locationDisplay.defaultSymbol = AGSPictureMarkerSymbol(image: UIImage(named: "current_location")!)
        mapView.locationDisplay.showAccuracy = false
        mapView.locationDisplay.autoPanMode = .off
        mapView.locationDisplay.dataSource = locationManager
        mapView.locationDisplay.start(completion: nil)
        
        schoolDropdown.delegate = self
        
        view.addSubview(mapView)
        view.addSubview(schoolDropdown)
        
        mapView.touchDelegate = self
        
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        schoolDropdown.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(68.0)
            make.leading.equalToSuperview().offset(16.0)
            make.trailing.equalToSuperview().offset(-16.0)
        }
        
        SchoolHolder.shared.loadSchoolCrimes(success: { schools in
            schools.forEach { self.placeMarkers(crimes: $0.crimes.value) }
            if let location = self.locationManager.locationManager.location {
                self.updateDangerStatus(location: location)
            }
        }) { error in
            print("failed to load crime stats with error: \(error)")
        }
    }
    
    func placeMarkers(crimes: [Crime]) {
        let colorMarkers = crimes.map { crime -> AGSGraphic in
            let sym = AGSSimpleMarkerSymbol(style: .circle, color: crime.category.color.withAlphaComponent(0.30), size: 50.0)
            return AGSGraphic(geometry: AGSPoint(clLocationCoordinate2D: crime.coordinate), symbol: sym)
        }
        
        let imageMarkers = crimes.compactMap { crime -> AGSGraphic? in
            guard let image = crime.category.image else { return nil }
            
            let marker = AGSPictureMarkerSymbol(image: image)
            return AGSGraphic(geometry: AGSPoint(clLocationCoordinate2D: crime.coordinate), symbol: marker)
        }
        
        let colorOverlay = AGSGraphicsOverlay()
        colorMarkers.forEach { colorOverlay.graphics.add($0) }
        
        let imageOverlay = AGSGraphicsOverlay()
        imageMarkers.forEach { imageOverlay.graphics.add($0) }
        
        mapView.graphicsOverlays.add(colorOverlay)
        mapView.graphicsOverlays.add(imageOverlay)
    }
    
    // MARK: school dropdown
    
    func schoolDropdown(_ view: SchoolDropdownView, didSelect item: String, at index: Int) {
        selectedSchool = SchoolHolder.shared.schools[index]
    }
    
    // MARK: touch delegate
    
    func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        if let crime = selectedSchool?.crimes.value.first(where: { crime in
            let coordinate = mapPoint.toCLLocationCoordinate2D()
            return abs(crime.point.lat - coordinate.latitude) < 0.0005 && abs(crime.point.lon - coordinate.longitude) < 0.0005
        }) {
            currentPopupView?.removeFromSuperview()
            
            let popupView = CrimeInfoPopupView(items: [
                (icon: "\u{e8a3}", value: Constants.dateFormatter.string(from: crime.start)),
                (icon: "\u{e873}", value: "Two suspects used force to intimidate USC students into giving up valuables."),
                (icon: "\u{eb41}", value: "20 y/o Asian Male"),
                (icon: "\u{e559}", value: "Tesla Model X")
                ])
            
            popupView.titleLabel.text = crime.title
            popupView.translatesAutoresizingMaskIntoConstraints = false
            popupView.transform = CGAffineTransform(translationX: 0.0, y: self.view.frame.size.height)
            
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.popupPanGestureRecognzier(_:)))
            popupView.addGestureRecognizer(panGestureRecognizer)
            
            view.addSubview(popupView)
            
            popupView.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
                popupView.transform = .identity
            }, completion: nil)
            
            self.currentPopupView = popupView
        }
    }
    
    // MARK: resture recognizers
    
    @objc private func popupPanGestureRecognzier(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            if popupFrame == nil { popupFrame = currentPopupView?.frame }
        } else if let popupView = currentPopupView, let popupFrame = popupFrame {
            if sender.state == .changed {
                let translatedPoint = sender.translation(in: view)
                var frame = popupView.frame
                
                frame.origin.y += translatedPoint.y
                frame.origin.y = min(view.frame.maxY, frame.origin.y)
                
                let yDiff = popupFrame.origin.y - frame.origin.y
                if yDiff > 0 {
                    frame.origin.y = popupView.frame.origin.y - (1 / yDiff)
                }
                
                currentPopupView?.frame = frame
                
                sender.setTranslation(CGPoint(x: 0.0, y: 0.0), in: view)
            } else if sender.state == .ended {
                let velocity = sender.velocity(in: view)
                
                if velocity.y > 500 || currentPopupView?.frame.minY ?? 0.0 > popupFrame.midY {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.currentPopupView?.transform = CGAffineTransform(translationX: 0.0, y: self.view.frame.size.height)
                    }) { _ in
                        self.currentPopupView?.removeFromSuperview()
                        self.currentPopupView = nil
                    }
                } else {
                    UIView.animate(withDuration: 0.3) {
                        self.currentPopupView?.frame = popupFrame
                    }
                }
            }
        }
    }
    
    // MARK: helper
    
    private func updateDangerStatus(location: CLLocation) {
        guard let school = selectedSchool else {
            schoolDropdown.dangerLevel = .ok
            return
        }
        
        let crimes = school.crimes.value.filter { abs($0.point.lat - location.coordinate.latitude) < 0.005 && abs($0.point.lon - location.coordinate.longitude) < 0.005 }
        
        if crimes.isEmpty {
            schoolDropdown.dangerLevel = .ok
        } else if crimes.contains(where: { $0.category.dangerLevel == .danger }) {
            schoolDropdown.dangerLevel = .danger
        } else {
            schoolDropdown.dangerLevel = .warning
        }
    }
}
