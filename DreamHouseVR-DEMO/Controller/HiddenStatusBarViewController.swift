//
//  HiddenStatusBarViewController.swift
//  DreamHouseVR-DEMO
//
//  Created by Petr Brantalík on 20/05/2020.
//  Copyright © 2020 Petr Brantalík. All rights reserved.
//

import UIKit

class HiddenStatusBarViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func prefersStatusBarHidden() -> Bool {
        return true
    }
    /*
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}


