//
//  LocationHelper.swift
//  Experiences
//
//  Created by Nelson Gonzalez on 3/22/19.
//  Copyright © 2019 Nelson Gonzalez. All rights reserved.
//

import Foundation
import CoreLocation

class LocationHelper: NSObject, CLLocationManagerDelegate {
    
    static var shared: LocationHelper = LocationHelper()
    
    lazy var locationManager: CLLocationManager = {
        let result = CLLocationManager()
        result.desiredAccuracy = kCLLocationAccuracyKilometer
        result.pausesLocationUpdatesAutomatically = true
        result.delegate = self
        return result
    }()
    
    //Get the users current location
    var currentLocation: CLLocation? {
        return locationManager.location
    }
    
    override init() {
        super.init()
        requestUserAuthorization()
    }
    
    func requestUserAuthorization() {
        locationManager.requestAlwaysAuthorization()//added
        locationManager.requestWhenInUseAuthorization()
        startTrackingLocation()
    }
    
    func startTrackingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopTrackingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    //CLLocationManagerDelegate method

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let _: CLLocationCoordinate2D = manager.location!.coordinate
        stopTrackingLocation()
    }
    
}
