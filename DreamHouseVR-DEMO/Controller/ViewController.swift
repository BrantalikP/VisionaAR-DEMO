//
//  AppDelegate.swift
//  DreamHouseVR-DEMO
//
//  Created by Petr Brantalík on 24/04/2020.
//  Copyright © 2020 Petr Brantalík. All rights reserved.
//


import UIKit
import FocusEntity
import RealityKit
import ARKit
import MultipeerConnectivity



class ViewController: UIViewController,ARSessionDelegate{
    
    @IBOutlet var arView: ARView!
    @IBOutlet weak var syncText: UILabel!
    let focusSquare = FESquare()
    var multipeerHelp = MultipeerHelper(
        serviceName: "helper-test"
    )
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupARView()
        setupMultipeer()
        setupGestures()
        arView.session.delegate = self
        focusSquare.synchronization = nil
        focusSquare.viewDelegate = arView
        
    }
    
    func session(_: ARSession, didUpdate _: ARFrame) {
        focusSquare.updateFocusEntity()
    }
    
    
    
    
    func setupARView() {
        arView.automaticallyConfigureSession = false
        arView.frame = view.bounds
        arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
//        self.arView.scene.synchronizationService = self.multipeerHelp.syncService
//        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal,.vertical]
        config.environmentTexturing = .automatic
        config.frameSemantics = .personSegmentationWithDepth
        config.isCollaborationEnabled = true
        arView.session.run(config)
        view.addSubview(arView)
    }
    
}

extension ViewController: UIGestureRecognizerDelegate {
    
    func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.arView.addGestureRecognizer(tap)
    }
    
    /// This function does sends a message "hello!" to all peers.
    /// If you tap on an existing entity, it will run a scale up and down animation
    /// If you tap on the floor without hitting any entities it will create a new Anchor
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if let myData = "hello! from \(self.multipeerHelp.myPeerID.displayName)"
            .data(using: .unicode)
        {
            multipeerHelp.sendToAllPeers(myData, reliably: true)
        }
        
        guard let touchInView = sender?.location(in: self.arView) else {
            return
        }
        if let hitEntity = self.arView.entity(at: touchInView) {
            // animate the Entity
            hitEntity.runWithOwnership { (result) in
                switch result {
                case .success:
                    let origTransform = Transform(scale: .one, rotation: .init(), translation: .zero)
                    let largerTransform = Transform(scale: .init(repeating: 1.5), rotation: .init(), translation: .zero)
                    hitEntity.move(to: largerTransform, relativeTo: hitEntity.parent, duration: 0.2)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        hitEntity.move(to: origTransform, relativeTo: hitEntity.parent, duration: 0.2)
                    }
                case .failure:
                    print("could not get access to entity")
                }
            }
        } else if let result = arView.raycast(
            from: touchInView,
            allowing: .existingPlaneGeometry, alignment: .horizontal
        ).first {
            self.addNewAnchor(transform: result.worldTransform)
        }
    }
    
    /// Add a new anchor to the session
    /// - Parameter transform: position in world space where the new anchor should be
    func addNewAnchor(transform: simd_float4x4) {
        let arAnchor = ARAnchor(name: "Cube Anchor", transform: transform)
        let newAnchor = AnchorEntity(anchor: arAnchor)
        
        let cubeModel = ModelEntity(
            mesh: .generateBox(size: 0.1),
            materials: [SimpleMaterial(color: .red, isMetallic: false)]
        )
        cubeModel.generateCollisionShapes(recursive: false)
        
        newAnchor.addChild(cubeModel)
        
        newAnchor.synchronization?.ownershipTransferMode = .autoAccept
        
        newAnchor.anchoring = AnchoringComponent(arAnchor)
        arView.installGestures([.rotation, .translation], for: cubeModel)
        arView.scene.addAnchor(newAnchor)
        arView.session.add(anchor: arAnchor)
        
    }
}

extension ViewController: MultipeerHelperDelegate {
  func setupMultipeer() {
    multipeerHelp = MultipeerHelper(
      serviceName: "helper-test",
      sessionType: .both,
      delegate: self
    )

    // MARK: - Setting RealityKit Synchronization

    guard let syncService = multipeerHelp.syncService else {
      fatalError("could not create multipeerHelp.syncService")
    }
    arView.scene.synchronizationService = syncService
  }

  func receivedData(_ data: Data, _ peer: MCPeerID) {
    print(String(data: data, encoding: .unicode) ?? "Data is not a unicode string")
  }

  func peerJoined(_ peer: MCPeerID) {
    print("new peer has joined: \(peer.displayName)")
  }
}
