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
import ReplayKit

protocol DataDelegate {
    func updateItem(name: String,category: String?)
}


class ViewController: UIViewController,ARSessionDelegate,DataDelegate{
    
    
    
    @IBOutlet weak var flashLightBtn: UIButton!
    @IBOutlet weak var toolBarBtn: UIButton!
    
    let MAX_EMPTY_TOUCHES = 5
    
    @IBOutlet var arView: ARView!
    @IBOutlet weak var isSelectedIndicator: UIView!
    @IBOutlet weak var syncIndicator: UIView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var syncImage: UIImageView!
    
    
    var emptyTouchCounter: Int = 0
    
    let focusSquare = FESquare()
    var multipeerHelp = MultipeerHelper(
        serviceName: "helper-test"
    )
    
    
    public var selectedItem: String?
    var preloadedEntity: Entity?
    
    
    // RECORD
    
    var recorder = RPScreenRecorder.shared()
    var isRecording = false
    @IBOutlet weak var recordBtn: UIButton!
    
    @IBOutlet weak var LibraryBtn: UIButton!
    
    //    var windowToHideHUD:UIWindow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        addButtons(buttons: [recordBtn])
        recordBtn.layer.cornerRadius = 15.0
        syncIndicator.layer.cornerRadius = 12.0
        isSelectedIndicator.layer.cornerRadius = 12.0
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        setupARView()
        setupMultipeer()
        setupGestures()
        arView.session.delegate = self
        focusSquare.synchronization = nil
        focusSquare.viewDelegate = arView
        
    }
    
    // for hide button in record preview
    //    func addButtons(buttons: [UIButton]) {
    //        self.windowToHideHUD = UIWindow(frame: self.view.frame);
    //        self.windowToHideHUD.rootViewController = HiddenStatusBarViewController()
    //        for button in buttons {
    //
    //            button.setTitle("dick", for: .normal)
    //            self.windowToHideHUD.rootViewController?.view.addSubview(button)
    //
    //             button.translatesAutoresizingMaskIntoConstraints = false
    //            let horizontalConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem:  self.windowToHideHUD.rootViewController?.view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0 )
    //
    //               let verticalConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem:  self.windowToHideHUD.rootViewController?.view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
    //
    //               let widthConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 100)
    //
    //               let heightConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 100)
    //
    //               self.windowToHideHUD.rootViewController?.view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    //
    //
    //        }
    //
    //
    //        self.windowToHideHUD.makeKeyAndVisible()
    //    }
    
    func session(_: ARSession, didUpdate _: ARFrame) {
        focusSquare.updateFocusEntity()
        
        //        if testEntity != nil{
        //
        //
        //            if entityScale != testEntity!.transform.scale {
        //
        //                let scaleX = testEntity!.transform.scale.x
        //                if let width = modelWidth,let height = modelHeight {
        //                    self.widthLabel.text = "width: \(Float(width) * scaleX)m"
        //                    self.heightLabel.text = "height: \(Float(height) * scaleX)m"
        //                }
        //
        //                entityScale  = testEntity!.transform.scale
        //
        //            }
        //
        //        }
        
        
        
        
    }
    
    
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
        //            for anchor in anchors {
        //                if let anchorName = anchor.name, anchorName == "ship"{
        //                    addNewAnchor(named: anchorName,for: anchor)
        //                }
        //
        //            }
        
        
        
        
        
        for anchor in anchors {
            
            
            for anchor in anchors {
                if let anchorName = anchor.name {
                    addNewAnchor(named: anchorName,for: anchor)
                    
                }}
            
            
            if let _ = anchor as? ARParticipantAnchor {
                print("Successfully connect with another user!")
                syncIndicator.isHidden = false
                
            }
        }
    }
    
    
    
    
    
    
    func setupARView() {
        arView.automaticallyConfigureSession = false
        arView.frame = view.bounds
        arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal,.vertical]
        config.environmentTexturing = .automatic
        config.frameSemantics = .personSegmentationWithDepth
        config.isCollaborationEnabled = true
        //        config.sceneReconstruction = .meshWithClassification
        arView.session.run(config)
        
        //        arView.debugOptions.insert(.showSceneUnderstanding)
        
        
    }
    
    
    @IBAction func libraryButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToLibrary", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToLibrary"{
            let destionationVC = segue.destination as! LibraryViewController
            destionationVC.delegate = self
            
        }
    }
    
    
    
    func updateItem(name: String,category: String?) {
        
        self.selectedItem = name
        isSelectedIndicator.isHidden = true
        if name != "cube" {
            
            
            preloadModel()
            
            
        }
        
        
        
        
    }
    
    func  calculateRealSize(at entity: Entity,by modelName: String) -> Transform {
        
        let bounds = entity.visualBounds(recursive: true, relativeTo: nil, excludeInactive: false)
        let width = CGFloat(bounds.max.x - bounds.min.x)
        
        
        let model = ModelService.shared.getModel(with: modelName)
        
        let calculatedScale = Float(CGFloat(model!.width!) / width)
        
        var newTransform = entity.transform
        newTransform.scale = .init(
            repeating: Float(calculatedScale)
        )
        
        return newTransform
    }
    
    
    
    
    func preloadModel(){
        
        
        if let currentItem = selectedItem {
            
            let model = ModelService.shared.getModel(with: currentItem)
            
            //let physics = Physics()
            preloadedEntity = try! ModelEntity.loadModel(named: currentItem)
            
            if model?.width != nil {
                
                let newTransform = calculateRealSize(at: preloadedEntity!,by: currentItem) // set model actual size
                preloadedEntity!.transform = newTransform
                
            }
            
            //let dynamicComponent: PhysicsBodyComponent = physics.physicsBody!
            //            let motionComponent: PhysicsMotionComponent = physics.physicsMotion!
            
            //preloadedEntity!.components.set(dynamicComponent)
            //            preloadedEntity!.components.set(motionComponent)
            
            
            preloadedEntity!.generateCollisionShapes(recursive: true)
            
            arView.installGestures([.rotation, .translation], for: preloadedEntity! as! HasCollision)
            
        }
        
        
    }
    
    
    //    @IBAction func resetTracking(_ sender: UIButton) {
    //        guard let configuration = arView.session.configuration else { print("A configuration is required"); return }
    //        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors,])
    //    }
    
    @IBAction func recordBtnPressed(_ sender: UIButton) {
        
        if !isRecording {
            startRecording()
        } else {
            stopRecording()
        }
    }
    
    @IBAction func cameraBtnPressed(_ sender: UIButton) {
        getScreenshot()
    }
    
    
    func toggleTorch() {
        guard
            let device = AVCaptureDevice.default(for: AVMediaType.video),
            device.hasTorch
            else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = device.torchMode == .on ? .off : .on
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used")
        }
    }
    
    func getScreenshot() {
        
        arView.snapshot(saveToHDR: false) { (image) in
            //Save it to the camera roll
            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        }
        
        
    }
    func saveImage(_ image: ARView.Image) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}


//MARK: - gesture handler
extension ViewController: UIGestureRecognizerDelegate {
    
    func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.arView.addGestureRecognizer(tap)
        let forceTouch = ForceTouchGestureRecognizer(target: self, action: #selector(forceTouchHandler))
        self.arView.addGestureRecognizer(forceTouch)
        
    }
    
    @objc func forceTouchHandler(_ sender: ForceTouchGestureRecognizer) {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        print("Force touch triggered")
        toggleTorch()
    }
    
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        
        
        
        // let aligment: ARRaycastQuery.TargetAlignment = selectedItem == "door" ? .vertical : .horizontal
        //"hello! from \(self.multipeerHelp.myPeerID.displayName)"
        let data = self.multipeerHelp.myPeerID.displayName
        
        if let myData = data
            .data(using: .unicode)
        {
            multipeerHelp.sendToAllPeers(myData, reliably: true)
        }
        
        guard let touchInView = sender?.location(in: self.arView) else {
            return
        }
        
        if let hitEntity = self.arView.entity(at: touchInView) {
            // hit the Entity
            hitEntity.runWithOwnership { (result) in
                switch result {
                case .success:
                    print("touch")
                case .failure:
                    print("could not get access to entity")
                }
            }
        } else if let result = arView.raycast(
            from: touchInView,
            allowing: .estimatedPlane, alignment: .horizontal
        ).first {
            if selectedItem != nil {
                let anchor = ARAnchor(name: selectedItem!, transform: result.worldTransform)
                arView.session.add(anchor: anchor)
                emptyTouchCounter = 0
            }else {
                emptyTouchCounter += 1
            }
            
            // isSelectedIndicator.isHidden = false
        } else {
            if selectedItem != nil {
                // not found surface with selected object
                //                print("not found surface with selected object")
            } else {
                emptyTouchCounter += 1
            }
            
        }
        
        
        
        
        
        if emptyTouchCounter == MAX_EMPTY_TOUCHES && isSelectedIndicator.isHidden {
            isSelectedIndicator.isHidden = false
            emptyTouchCounter = 0
        }
    }
    
    
    
    
    
    
    /// Add a new anchor to the session
    /// - Parameter transform: position in world space where the new anchor should be
    func addNewAnchor(named entityName: String, for anchor: ARAnchor) {
        
        //
        //        let otherPeer = self.multipeerHelp.connectedPeers.first?.displayName
        //        print(otherPeer)
        //
        
        if entityName == "cube"  {
            addTestCube(for: anchor)
        }
        else {
            
            
            
            let anchorEntity = AnchorEntity(anchor: anchor)
            
            anchorEntity.synchronization?.ownershipTransferMode = .autoAccept
            
            if preloadedEntity == nil {
                //let physics = Physics()
                let entity = try! ModelEntity.loadModel(named: entityName)
                
                
                let model = ModelService.shared.getModel(with: entityName)
                
                if model?.width != nil {
                    
                    let newTransform = calculateRealSize(at: entity,by: entityName) // set model actual size
                    entity.transform = newTransform
                    
                }
                
                
                //let dynamicComponent: PhysicsBodyComponent = physics.physicsBody!
                //                let motionComponent: PhysicsMotionComponent = physics.physicsMotion!
                
                //entity.components.set(dynamicComponent)
                //                entity.components.set(motionComponent)
                entity.generateCollisionShapes(recursive: true)
                arView.installGestures([.rotation, .translation], for: entity)
                
            } else {
                anchorEntity.addChild(preloadedEntity!)
                
                anchorEntity.anchoring = AnchoringComponent(anchor)
                anchorEntity.synchronization?.ownershipTransferMode = .autoAccept
                
                arView.scene.addAnchor(anchorEntity)
                selectedItem = nil
                preloadedEntity = nil
            }
            
            
            
            
        }
        
        
        
        
        
    }
    
    func addTestCube(for anchor: ARAnchor){
        
        let name = self.multipeerHelp.myPeerID.displayName
        let newAnchor = AnchorEntity(anchor: anchor)
        let color = name == "Lenka’s iPad" ? UIColor.blue : UIColor.red
        let cubeModel = ModelEntity(
            mesh: .generateBox(size: 0.1),
            materials: [SimpleMaterial(color: color, isMetallic: false)]
        )
        cubeModel.generateCollisionShapes(recursive: false)
        
        newAnchor.addChild(cubeModel)
        
        newAnchor.synchronization?.ownershipTransferMode = .autoAccept
        
        newAnchor.anchoring = AnchoringComponent(anchor)
        arView.installGestures([.rotation, .translation], for: cubeModel)
        arView.scene.addAnchor(newAnchor)
        arView.session.add(anchor: anchor)
        selectedItem = nil
    }
    
    
    
    
}


//MARK: - MultipeerSetup and Delegate
extension ViewController: MultipeerHelperDelegate {
    func setupMultipeer() {
        multipeerHelp = MultipeerHelper(
            serviceName: "dreamhouse-demo",
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
        print("Recieved Data")
        
        if let recievedData = String(data: data, encoding: .unicode) {
            print(recievedData)
            
            //            if recievedData != "cube" && recievedData != selectedItem {
            //                preloadedEntity = try! ModelEntity.loadModel(named: String(recievedData))
            //            }
            
        }
        
    }
    
    func peerJoined(_ peer: MCPeerID) {
        print("new peer has joined: \(peer.displayName)")
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
        //            self.syncText.text = "Sync!"
        //                 }
        
    }
    
    func peerLeft(_ peer: MCPeerID) {
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
        //            self.syncText.text = "Async!"
        //        }
    }
    
    
}
