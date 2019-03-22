//
//  ExperienceViewController.swift
//  Experiences
//
//  Created by Nelson Gonzalez on 3/22/19.
//  Copyright © 2019 Nelson Gonzalez. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class ExperienceViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var recordAudioButton: UIButton!
    @IBOutlet weak var playAudioButton: UIButton!
    
    
    var filteredImage: UIImage?
    
    var originalImage: UIImage? {
        didSet {
            updateImageViews()
        }
    }
    
    private let filterEffect = CIFilter(name: "CIPhotoEffectTonal")
    private let context = CIContext(options: nil)
    
    private var player: AVAudioPlayer?
    
    var isPlaying: Bool {
        return player?.isPlaying ?? false
    }
    
    private var recorder: AVAudioRecorder?
    var isRecording: Bool {
        return recorder?.isRecording ?? false
    }
    
    //the url of the most recently recorded audio recording
    var recordingUrl: URL?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        player?.delegate = self
        recorder?.delegate = self
       
    }
    
    func updateImageViews() {
        guard let img = originalImage else {return}
        
        imageView.image = applyImageFilter(to: img)
        
        filteredImage = applyImageFilter(to: img)
    }
    
    private func applyImageFilter(to image: UIImage) -> UIImage {
        
        guard let cgImage = image.cgImage else {return image}
        let ciImage = CIImage(cgImage: cgImage)
        
        
        filterEffect?.setValue(ciImage, forKey: "inputImage")
        
        guard let outputImage = filterEffect?.outputImage else {
            return image
        }
        
        guard let cgImages = context.createCGImage(outputImage, from: outputImage.extent) else {
            return image
        }
        return UIImage(cgImage: cgImages)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        originalImage = info[.originalImage] as? UIImage
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    private func newRecordingUrl() -> URL {
        
        let documentsDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        return documentsDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("caf")
    }
    
    
    private func updateButtons() {
        
        let playAudioButtonTitle = isPlaying ? "Stop Playing" : "Play"
        playAudioButton.setTitle(playAudioButtonTitle, for: .normal)
        
        let recordAudioButtonTitle = isRecording ? "Stop Recoring" : "Record"
        recordAudioButton.setTitle(recordAudioButtonTitle, for: .normal)
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateButtons()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        updateButtons()
        
        recordingUrl = recorder.url
        
    }
    
    func saveImage(image: UIImage) -> URL {
        
        guard let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { fatalError("No access to documents directory at this time") }
        
        let filesURL = documentsDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpeg")
        guard let data = image.jpegData(compressionQuality: 0.8) else { fatalError("No data returned") }
        
        if FileManager.default.fileExists(atPath: filesURL.path) {
            do {
                try FileManager.default.removeItem(atPath: filesURL.path)
            } catch {
                NSLog("Could not delete the file at path: \(filesURL.path)")
            }
        }
        
        do {
            try data.write(to: filesURL)
        } catch {
            NSLog("There was an error while trying to save/write to file.")
        }
        
        return filesURL
        
    }
    

   
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toVideoVC" {
            let destinationVC = segue.destination as? VideoRecordingViewController
            guard let image = imageView.image, let audioURL = recordingUrl else { return}
            
            destinationVC?.audioURL = audioURL
            destinationVC?.imageURL = saveImage(image: image)
            destinationVC?.titleTextString = titleTextField.text
        }
    }
    
    
    @IBAction func addImageButtonPressed(_ sender: UIButton) {
        let picker = UIImagePickerController()
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            
            let alert = UIAlertController(title: "Error", message: "Could not reach photo library at this time", preferredStyle: .alert)
            
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(alertAction)
            
            present(alert, animated: true, completion: nil)
            
            return
        }
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
        
        
    }
    @IBAction func recordAudioButtonPressed(_ sender: UIButton) {
        if isRecording {
            recorder?.stop()
            return
        }
        
        do {
            //Choose the format
            let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2)!
            recorder = try AVAudioRecorder(url: newRecordingUrl(), format: format)
            recorder?.record()
            recorder?.delegate = self
        } catch {
            NSLog("Unable to start recoring: \(error)")
        }
        
        updateButtons()
        
    }
    @IBAction func playAudioButtonPressed(_ sender: UIButton) {
       
        guard let recordingUrl = recordingUrl else {return}
        
        if isPlaying {
            player?.stop()
            return
        }
        
        //create player and tell it to start playing
        do {
            //Set up the player with the sample audio file
            player = try AVAudioPlayer(contentsOf: recordingUrl)
            
            player?.play()
            
            //the VC adding itself as the observer of the delegate method.
            player?.delegate = self
        } catch {
            NSLog("Error attmepting to start playing audio: \(error)")
        }
        
        updateButtons()
        
        
    }
    @IBAction func nextBarButtonPressed(_ sender: UIBarButtonItem) {
        
        guard let title = titleTextField.text, !title.isEmpty, (recordingUrl != nil) else {
            
            let alert = UIAlertController(title: "Error", message: "Please Enter Title Text!", preferredStyle: .alert)
            
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(alertAction)
            
            present(alert, animated: true, completion: nil)
            return
            
        }
        performSegue(withIdentifier: "toVideoVC", sender: self)
        
    }
    
    

}
