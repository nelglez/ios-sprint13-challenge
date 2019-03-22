//
//  VideoRecordingViewController.swift
//  Experiences
//
//  Created by Nelson Gonzalez on 3/22/19.
//  Copyright © 2019 Nelson Gonzalez. All rights reserved.
//

import UIKit

class VideoRecordingViewController: UIViewController {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var cameraPreview: CameraPreviewView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        
        
    }
    @IBAction func saveBarButtonPressed(_ sender: UIBarButtonItem) {
    }
    

}
