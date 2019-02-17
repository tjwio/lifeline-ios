//
//  HomeViewController.swift
//  lifeline
//
//  Created by Tim Wong on 2/16/19.
//  Copyright © 2019 tjwio. All rights reserved.
//

import UIKit
import ArcGIS
import SnapKit

class HomeViewController: UIViewController, SchoolDropdownViewDelegate {
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        schoolDropdown.delegate = self
        
        view.addSubview(mapView)
        view.addSubview(schoolDropdown)
        
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
        let school = SchoolHolder.shared.schools[index]
        
        mapView.setViewpoint(AGSViewpoint(center: AGSPoint(clLocationCoordinate2D: school.category.coordinate), scale: 1.5e4))
    }
}
