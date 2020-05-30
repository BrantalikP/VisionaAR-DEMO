//
//  Entity.swift
//  DreamHouseVR-DEMO
//
//  Created by Petr Brantalík on 30/05/2020.
//  Copyright © 2020 Petr Brantalík. All rights reserved.
//

import ARKit
import RealityKit

class Physics: Entity, HasPhysicsBody, HasPhysicsMotion {

    required init() {
        super.init()

        self.physicsBody = PhysicsBodyComponent(massProperties: .default,
                                                      material: nil,
                                                      mode: .dynamic)

        self.physicsMotion = PhysicsMotionComponent(linearVelocity: [0.1, 0, 0],
                                                   angularVelocity: [1, 3, 5])
    }
}
