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
  
    
    var mainController = ViewController()
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    var delegate: DataDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        background.backgroundColor = UIColor.red
         
     
        loader.hidesWhenStopped = true
        
    }
    
    @IBAction func closeLibrary(_ sender: UIButton) {
      
      
        loader.startAnimating()
        delegate?.updateItem(name:"ship")
        loader.stopAnimating()
        dismiss(animated: true, completion: nil)
    }
    

}
