//
//  ViewController.swift
//  Experiences
//
//  Created by Nelson Gonzalez on 3/22/19.
//  Copyright © 2019 Nelson Gonzalez. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    let locationHelper = LocationHelper()
    var experienceController: ExperienceController?
    var experience: [Experience] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addAnnotation()
        
        mapView.delegate = self
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "ExperienceAnnotationView")
        
        //  mapView.showsUserLocation = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addAnnotation()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        zoomToUsersLocation()
    }
    
    func addAnnotation() {
        
        mapView.removeAnnotations(mapView.annotations)
        guard let experience = experienceController?.experiences else {return}
        mapView.addAnnotations(experience)
        
        let myPin = MKPointAnnotation()
        if let myCoordinate = experienceController?.newExperiences?.coordinate {
            myPin.coordinate = myCoordinate
        }
        if let annotationText = experienceController?.newExperiences?.postTitle {
            myPin.title = annotationText
        }
        mapView.addAnnotation(myPin)
    }
    
    func zoomToUsersLocation() {
        //Zoom to user location
        if let location = locationHelper.currentLocation?.coordinate {
            let viewRegion = MKCoordinateRegion(center: location, latitudinalMeters: 11500, longitudinalMeters: 11500)
            mapView.setRegion(viewRegion, animated: true)
        }
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let experience = annotation as? Experience else {return nil}
        
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "ExperienceAnnotationView", for: experience) as? MKMarkerAnnotationView
      
        //annotationView?.glyphText = experience.postTitle
        annotationView?.glyphTintColor = .white
        //annotationView?.markerTintColor = .blue
        annotationView?.titleVisibility = .visible
        
        return annotationView
        
    }

}

