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
        let mapView = AGSMapView()
        mapView.map = AGSMap(basemap: .streetsNightVector())
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        return mapView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        view.addSubview(mapView)
        
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
