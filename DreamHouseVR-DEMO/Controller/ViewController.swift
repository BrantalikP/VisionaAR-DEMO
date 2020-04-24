//
//  ViewController.swift
//  DreamHouseVR-DEMO
//
//  Created by Petr Brantalík on 24/04/2020.
//  Copyright © 2020 Petr Brantalík. All rights reserved.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController, ARSessionDelegate {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupARView()
                   
                
                   
        arView.session.delegate = self
                   
              
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()

        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
    }

    
//     override func viewDidAppear(_ animated: Bool) {
//            super.viewDidAppear(animated)
//
//            setupARView()
//
//
//
//            arView.session.delegate = self
//
//
//        }
    
    func setupARView(){
          arView.automaticallyConfigureSession = false
          
          let config = ARWorldTrackingConfiguration()
          config.planeDetection = [.horizontal,.vertical]
          config.environmentTexturing = .automatic
          config.frameSemantics = .personSegmentationWithDepth
          config.isCollaborationEnabled = true
       
          
          arView.session.run(config)
      }
}
