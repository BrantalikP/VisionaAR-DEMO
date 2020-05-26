//
//  ScreenRecord.swift
//  DreamHouseVR-DEMO
//
//  Created by Petr Brantalík on 20/05/2020.
//  Copyright © 2020 Petr Brantalík. All rights reserved.
//


import ReplayKit
import UIKit

extension ViewController:RPPreviewViewControllerDelegate {
    
    func startRecording() {
        guard recorder.isAvailable else {
            print("Recording is not available at this time.")
            return
        }
        
        
        recorder.isMicrophoneEnabled = true
        recorder.startRecording { (error) in
            guard error == nil else {
                print("There was an error starting the recording.")
                return
            }
            
            print("STARTED RECORDING SUCCESSFULLY!")
            DispatchQueue.main.async {
                self.recordBtn.setTitle("STOP", for: .normal)
                self.recordBtn.backgroundColor = #colorLiteral(red: 0.6257185723, green: 0.08509886337, blue: 0.08477386882, alpha: 1)
                self.isRecording = true
            }
        }
    }
    
    func stopRecording() {
        
//        self.windowToHideHUD.isHidden = true;
                       
        recorder.stopRecording { (preview, error) in
            guard preview != nil else {
                print("Preview controller is not available.")
                return
            }
           
                  
            let alert = UIAlertController(title: "Recording Finished", message: "Would you like to edit or delete your recording?", preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                self.recorder.discardRecording {
                    print("Recording successfully deleted!")
                }
            })
            
            let editAction = UIAlertAction(title: "Edit", style: .default, handler: { (action) in
                preview?.previewControllerDelegate = self
                self.present(preview!, animated: true, completion: nil)
            })
//
//            let editAction = UIAlertAction(title: "View", style: .default, handler: { (action: UIAlertAction) -> Void in
//                         self.buttonWindow.rootViewController?.present(preview!, animated: true, completion: nil)
//                     })
                      
            
            alert.addAction(deleteAction)
            alert.addAction(editAction)
            self.present(alert, animated: true, completion: nil)
            
            self.isRecording = false
            self.viewReset()
        }
    }
    
    func viewReset() {
         self.recordBtn.setTitle("REC", for: .normal)
    }
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
           dismiss(animated: true, completion: nil)
//        self.windowToHideHUD.isHidden = false;
       }
}
