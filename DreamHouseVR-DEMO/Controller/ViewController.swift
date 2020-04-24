//
//  AppDelegate.swift
//  DreamHouseVR-DEMO
//
//  Created by Petr Brantalík on 24/04/2020.
//  Copyright © 2020 Petr Brantalík. All rights reserved.
//


import UIKit
import RealityKit
import ARKit



class ViewController: UIViewController{
    
    @IBOutlet var arView: ARView!
    @IBOutlet weak var syncText: UILabel!
    
    var multipeerSession: MultipeerSession!
    var sessionIDoBservation: NSKeyValueObservation?
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupARView()
        
        setupMultiPeerSession()
        
        arView.session.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        arView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    
    func setupARView(){
        arView.automaticallyConfigureSession = false
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal,.vertical]
        config.environmentTexturing = .automatic
        config.frameSemantics = .personSegmentationWithDepth
        config.isCollaborationEnabled = true
        
        arView.session.run(config)
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer){
        
        let location = recognizer.location(in: arView)
        print("location")
        print(location)
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let firstResult = results.first{
            
            let anchor = ARAnchor(name: "ship", transform: firstResult.worldTransform)
            arView.session.add(anchor: anchor)
            
            
        }else {
            print("failed couldt find surface")
        }
    }
    
    
    
    func setupMultiPeerSession(){
        sessionIDoBservation = observe(\.arView.session.identifier,options: [.new]) {
            object,change in print("SeesionID changed to: \(change.newValue!)")
            
            guard let multipeerSession = self.multipeerSession else {return}
            self.sendARSessionIDTo(peers: multipeerSession.connectedPeers)
        }
        
        multipeerSession = MultipeerSession(serviceName: "multiuser-ar", receivedDataHandler: self.receivedData, peerJoinedHandler: self.peerJoined, peerLeftHandler: self.peerLeft, peerDiscoveredHandler: self.peerDiscovered)
    }
    
    func placeObject(named entityName: String, for anchor: ARAnchor){
        
        let entity = try! ModelEntity.loadModel(named: entityName)
        
        entity.generateCollisionShapes(recursive: true)
        arView.installGestures([.rotation, .translation], for: entity)
        
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(entity)
      
        arView.scene.addAnchor(anchorEntity)
    }
}



extension ViewController: ARSessionDelegate {
    
    
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name, anchorName == "ship"{
                placeObject(named: anchorName,for: anchor)
            }
            
            
            if let _ = anchor as? ARParticipantAnchor {
                print("Successfullz connect with another user!")
               syncText.text = "Sync!"
                
//                let anchorEntity = AnchorEntity(anchor: participantAnchor)
//                let mesh = MeshResource.generateSphere(radius: 0.03)
//                let color = UIColor.red
//                let material = SimpleMaterial(color: color, isMetallic: false)
//                let coloredSphere = ModelEntity(mesh: mesh, materials: [material])
//                anchorEntity.addChild(coloredSphere)
//
//                arView.scene.addAnchor(anchorEntity)
            }
        }
    }
}


//MARK: - MultipeerSession
extension ViewController {
    
    
    
    private func sendARSessionIDTo(peers: [PeerID]){
        guard let multipeerSession = multipeerSession else {return}
        let idString = arView.session.identifier.uuidString
        let command = "SessionID:" + idString
        if let commandData = command.data(using: .utf8){
            multipeerSession.sendToPeers(commandData, reliably: true, peers: peers)
        }
    }
    
    
    func receivedData(_ data: Data, from peer: PeerID) {
        guard let multipeerSession = multipeerSession else {return}
        if let collaborationData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARSession.CollaborationData.self, from: data) {
            arView.session.update(with: collaborationData)
            return
        }
        // ...
        let sessionIDCommandString = "SessionID:"
        if let commandString = String(data: data, encoding: .utf8), commandString.starts(with: sessionIDCommandString) {
            let newSessionID = String(commandString[commandString.index(commandString.startIndex,
                                                                        offsetBy: sessionIDCommandString.count)...])
            // If this peer was using a different session ID before, remove all its associated anchors.
            // This will remove the old participant anchor and its geometry from the scene.
            if let oldSessionID = multipeerSession.peerSessionIDs[peer] {
                removeAllAnchorsOriginatingFromARSessionWithID(oldSessionID)
            }
            
            multipeerSession.peerSessionIDs[peer] = newSessionID
        }
    }
    
    
    
    func peerDiscovered(_ peer: PeerID) -> Bool {
        guard let multipeerSession = multipeerSession else { return false }
        
        if multipeerSession.connectedPeers.count > 4 {
            // Do not accept more than four users in the experience.
            print("A fifth peer wants to join the experience.\nThis app is limited to four users.")
            return false
        } else {
            return true
        }
    }
    /// - Tag: PeerJoined
    func peerJoined(_ peer: PeerID) {
        print("""
             A peer wants to join the experience.
             Hold the phones next to each other.
             """)
        // Provide your session ID to the new user so they can keep track of your anchors.
        sendARSessionIDTo(peers: [peer])
    }
    
    func peerLeft(_ peer: PeerID) {
        guard let multipeerSession = multipeerSession else {return}
        print("player left the game")
        // Remove all ARAnchors associated with the peer that just left the experience.
        if let sessionID = multipeerSession.peerSessionIDs[peer] {
            removeAllAnchorsOriginatingFromARSessionWithID(sessionID)
            multipeerSession.peerSessionIDs.removeValue(forKey: peer)
        }
    }
    
    private func removeAllAnchorsOriginatingFromARSessionWithID(_ identifier: String) {
        guard let frame = arView.session.currentFrame else { return }
        for anchor in frame.anchors {
            guard let anchorSessionID = anchor.sessionIdentifier else { continue }
            if anchorSessionID.uuidString == identifier {
                arView.session.remove(anchor: anchor)
            }
        }
    }
    
    func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {
        guard let multipeerSession = multipeerSession else { return }
        if !multipeerSession.connectedPeers.isEmpty {
            guard let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true)
                else { fatalError("Unexpectedly failed to encode collaboration data.") }
            // Use reliable mode if the data is critical, and unreliable mode if the data is optional.
            
            let dataIsCritical = data.priority == .critical
            multipeerSession.sendToAllPeers(encodedData, reliably: dataIsCritical)
        } else {
            print("Deferred sending collaboration to later because there are no peers.")
        }
    }
    
}
