//
//  CategoryService.swift
//  DreamHouseVR-DEMO
//
//  Created by Petr Brantalík on 17/05/2020.
//  Copyright © 2020 Petr Brantalík. All rights reserved.
//

import Foundation


class CategoryService {
    static let shared = CategoryService()
    
    private var categories = [Category]()
    
    private init() {
        categories = [Category(name: "All"),Category(name: "Chair"),Category(name: "Bed"),Category(name: "Table"),Category(name: "Sofa")]
    }
    
    func getCategories() -> [Category]{
        return categories
    }
}
