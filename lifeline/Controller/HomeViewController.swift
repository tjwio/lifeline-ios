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

class HomeViewController: UIViewController {
    
    let mapView: AGSMapView = {
        let map = AGSMap(basemap: .streetsNightVector())
        map.initialViewpoint = AGSViewpoint(center: AGSPoint(clLocationCoordinate2D: Student.usc.coordinate), scale: 1.5e4)
        
        let mapView = AGSMapView()
        mapView.map = map
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        return mapView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        NetworkManager.shared.loadCrimeStats(neighbourhood: Student.usc.neighbourhood, startDate: Calendar.current.date(byAdding: .month, value: -1, to: Date())!, endDate: Date(), success: { crimes in
            self.placeMarkers(crimes: crimes)
        }) { error in
            print("failed to load crime stats with error: \(error)")
        }
    }
    
    func placeMarkers(crimes: [Crime]) {
        let colorMarkers = crimes.map { crime -> AGSGraphic in
            let sym = AGSSimpleMarkerSymbol(style: .circle, color: UIColor.Red.normal.withAlphaComponent(0.30), size: 50.0)
            return AGSGraphic(geometry: AGSPoint(clLocationCoordinate2D: crime.coordinate), symbol: sym)
        }
        
        let imageMarkers = crimes.compactMap { crime -> AGSGraphic? in
            guard let image = crime.image else { return nil }
            
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
}
