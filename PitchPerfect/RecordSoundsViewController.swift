//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Joseph Powell on 11/11/21.
//  Copyright © 2021 Joseph Powell. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController,  AVAudioRecorderDelegate {

    var audioRecorder: AVAudioRecorder!
    
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Ask for microphone permission
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            updateUI(recording: false)
        
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                if granted {
                    // This is not main thread, so force main thread
                    DispatchQueue.main.async {
                        self.updateUI(recording: false)
                    }
                }
            }
            
        case .denied:
            return
        
        case .restricted:
            return
        
        @unknown default:
            return
        }
        
        print("viewDidLoad")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("viewWillAppear")
    }

    // MARK: Record Audio - records and saves audio file
    @IBAction func recordAudio(_ sender: Any) {

        updateUI(recording: true)
        
        //alternate way to grab first element of array and unwrap optional string (!)
//        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true).first!
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
//        for stuff in pathArray{
//         print(stuff)
//        }
    
        //Combine paths
        let filePath = URL(string: pathArray.joined(separator: "/"))
        print(filePath!)

        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)

        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self   // set view controller as delegate to the AVaudioRecorder, view controller will handle events that AVaudioRecorder hands to it
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    //MARK: Stop Recording
    @IBAction func stopRecording(_ sender: Any) {
        
        updateUI(recording: false)
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    //MARK: Segue - transition view controller when recording finishes
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("audio recorded successfully.")
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        }
        else {
            print("recording unsuccessful")
        }
    }
    
    //MARK: Prepare Segue - pass parameters to PlaySoundsViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
    
    //MARK: Update UI depending on the state of recording
    func updateUI(recording: Bool) {
        if recording {
            recordLabel.text = "Recording in Progress..."
            recordButton.isEnabled = false
            stopRecordingButton.isEnabled = true
        }
        else {
	            recordLabel.text = "Tap to Record"
            recordButton.isEnabled = true
            stopRecordingButton.isEnabled = false
        }
    }
    
}

