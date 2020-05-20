//
//  ModelService.swift
//  DreamHouseVR-DEMO
//
//  Created by Petr Brantalík on 17/05/2020.
//  Copyright © 2020 Petr Brantalík. All rights reserved.
//

import Foundation



class ModelService {
    static let shared = ModelService()
    
    private var models = [Model]()
    
    private init() {
        models = [Model(name: "cube", colors: []),Model(name: "sofa", colors: [],category: "Sofa"),Model(name: "door", colors: []),Model(name: "chair", colors: ["brown","red","green"],category: "Chair"),Model(name: "mini-desk", colors: [],category: "Table"),Model(name: "bed", colors: [],category:"Bed"),Model(name: "small-chair", colors: [],category: "Chair",width: 0.98),Model(name: "desk", colors: [],category: "Table"),Model(name: "kancl-stul", colors: [],category: "Table"),Model(name: "kancl-zidle-1", colors: [],category: "Chair"),Model(name: "kancl-zidle-2", colors: [],category: "Chair"),Model(name: "l-sofa-grey", colors: [],category: "Sofa",width: 2.92),Model(name: "brantalik", colors: [],category: "Sofa",width: 2.92)]
           
    }
    
    func getModels() -> [Model] {
        return models
    }
    
    func getModel(with modelName: String) -> Model? {
     
        if let index = models.firstIndex(where: { $0.name == modelName }) {
         
            return models[index]
        }
        return nil
    }
    

}
