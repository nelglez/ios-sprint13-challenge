//
//  ExperienceController.swift
//  Experiences
//
//  Created by Nelson Gonzalez on 3/22/19.
//  Copyright © 2019 Nelson Gonzalez. All rights reserved.
//

import UIKit
import MapKit

class ExperienceController {
    
    var newExperiences: Experience?
    private(set) var experiences: [Experience] = []
    
    
    
    func createExperience(with postTitle: String, audioURL: URL, videoURL: URL, image: URL, coordinate: CLLocationCoordinate2D)  {
        
        let newExperience = Experience(postTitle: postTitle, audioURL: audioURL, videoURL: videoURL, image: image, coordinate: coordinate)
        
        experiences.append(newExperience)
        newExperiences = newExperience
    }
    
}
