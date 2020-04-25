//
//  LibraryViewController.swift
//  DreamHouseVR-DEMO
//
//  Created by Petr Brantalík on 25/04/2020.
//  Copyright © 2020 Petr Brantalík. All rights reserved.
//

import UIKit


class LibraryViewController: UIViewController {
    @IBOutlet var background: UIView!
    
    var viewController = ViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        background.backgroundColor = UIColor.red
        
     
        
        
    }
    
    @IBAction func closeLibrary(_ sender: UIButton) {
       
        dismiss(animated: true, completion: nil)
    }
    

}
