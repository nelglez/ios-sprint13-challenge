//
//  Experience.swift
//  Experiences
//
//  Created by Nelson Gonzalez on 3/22/19.
//  Copyright © 2019 Nelson Gonzalez. All rights reserved.
//


import UIKit
import MapKit

class Experience: NSObject, MKAnnotation {
    
    var postTitle: String
    var audioURL: URL
    var videoURL: URL
    var image: URL
    var coordinate: CLLocationCoordinate2D
    
    init(postTitle: String, audioURL: URL, videoURL: URL, image: URL, coordinate: CLLocationCoordinate2D) {
        self.postTitle = postTitle
        self.audioURL = audioURL
        self.videoURL = videoURL
        self.image = image
        self.coordinate = coordinate
    }
    
}
