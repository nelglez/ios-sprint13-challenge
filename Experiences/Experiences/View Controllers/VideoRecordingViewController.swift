//
//  VideoRecordingViewController.swift
//  Experiences
//
//  Created by Nelson Gonzalez on 3/22/19.
//  Copyright © 2019 Nelson Gonzalez. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import CoreLocation


class VideoRecordingViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var cameraPreview: CameraPreviewView!
    
    let experienceController = ExperienceController()
    var imageURL: URL?
    var titleTextString: String?
    var audioURL: URL?
    var videoURL: URL?
    var cLLocation: CLLocationCoordinate2D?
    var captureSession = AVCaptureSession()
    var recordOutput = AVCaptureMovieFileOutput()
    var locationManager: CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        authorizeCameraAccess()
        setupCaptureSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        captureSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        captureSession.stopRunning()
    }
    
    private func updateViews() {
        
        let isRecording = recordOutput.isRecording
        
        let recordButtonImage = isRecording ? "Stop" : "Record"
        recordButton.setImage(UIImage(named: recordButtonImage), for: .normal)
        
    }
    
    private func authorizeCameraAccess() {
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        //the user has previouslty given authorization to use the camera
        case .authorized:
            print("Authorized")
        case .notDetermined:
            
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted {
                    print("Authorized")
                } else {
                    //Show alert saying they cant use the app becasue they didnt allow camera access
                }
            }
            
        case .restricted:
            //the user has restrictions such as parental control, limiting access to their hardware
            return
        case .denied:
            //the user has previsouly denied access to the camera. Prompt them to go to settings anx allow access.
            //user url scheme to show them the settings view
            return
        }
        
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        DispatchQueue.main.async {
            self.updateViews()
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        self.videoURL = outputFileURL
        DispatchQueue.main.async {
            
            defer {self.updateViews()}
            
            PHPhotoLibrary.requestAuthorization({ (status) in
                guard status == .authorized else {
                    NSLog("Please give video filterd access to photo library in settings")
                    return
                }
                
                PHPhotoLibrary.shared().performChanges({
                    PHAssetCreationRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
                    
                }, completionHandler: { (success, error) in
                    //remove it from documents. we just want one in the photo library. This removes it
                    try! FileManager.default.removeItem(at: outputFileURL)
                    
                    if let error = error {
                        NSLog("Error saving video to phopto library: \(error)")
                    }
                })
            })
        }
    }
    
    func setupCaptureSession() {
        //make the capture session
        let captureSession = AVCaptureSession()
        //configure the inputs
        let cameraDevice = bestCamera()
        
        guard let audioDevice = AVCaptureDevice.default(for: .audio) else {return}
        
        guard let cameraDeviceInput = try? AVCaptureDeviceInput(device: cameraDevice), /* guard */ captureSession.canAddInput(cameraDeviceInput) else {
            fatalError("Unable to create camera input")
        }
        
        guard let audioDeviceInput = try? AVCaptureDeviceInput(device: audioDevice) else {return}
        
        //"take this camera and use it to record video when the session begins"
        captureSession.addInput(cameraDeviceInput)
        captureSession.addInput(audioDeviceInput)
        
        //configure outputs
        let fileOutput = AVCaptureMovieFileOutput()
        
        guard captureSession.canAddOutput(fileOutput) else {
            fatalError("Unable to add movie file output to capture session")
        }
        
        captureSession.addOutput(fileOutput)
        
        //configure the session
        
        captureSession.sessionPreset = .hd1920x1080
        //ready to begin running everything
        captureSession.commitConfiguration()//lock in the inputs, outputs, session presets, etc
        
        self.captureSession = captureSession
        self.recordOutput = fileOutput
        
        //gives the video information frames to the preview view to be shown to the user
        cameraPreview.videoPreviewLayer.session = captureSession
        
    }
    
    private func saveVideoRecording(with url: URL) {
        
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            PHPhotoLibrary.shared().performChanges({
                PHAssetCreationRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }, completionHandler: { (success, error) in
                if let error = error {
                    NSLog("there was an error saving photo: \(error)")
                } else {
                    //show alert
                }
            })
        }
    }
    

    private func bestCamera() -> AVCaptureDevice {
        //the users device has a dual camera
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return device
        } else  if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            //single camera on users device
            return device
            
        } else {
            fatalError("Missing expected back camera on device")
        }
        
    }
    
    
    private func newRecordingURL() -> URL {
        
        let documentDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        return documentDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapVC" {
            let destinationVC = segue.destination as? MapViewController
            destinationVC?.experienceController = experienceController
            destinationVC?.experience = experienceController.experiences
        }
    }
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        
        if recordOutput.isRecording {
            recordOutput.stopRecording()
        } else {
            recordOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
        
    }
    @IBAction func saveBarButtonPressed(_ sender: UIBarButtonItem) {
        
        guard let title = self.titleTextString,
            let audioURL = self.audioURL,
            let videoURL = self.videoURL,
            let imageURL = self.imageURL else { return}
        
        experienceController.createExperience(with: title, audioURL: audioURL, videoURL: videoURL, image: imageURL, coordinate: LocationHelper.shared.currentLocation?.coordinate ?? kCLLocationCoordinate2DInvalid)
        
        performSegue(withIdentifier: "toMapVC", sender: self)
        
    }
    

}
