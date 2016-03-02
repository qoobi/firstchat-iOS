//
//  ThirdViewController.swift
//  firstchat
//
//  Created by Mikhail Gilmutdinov on 26.02.16.
//  Copyright © 2016 Mikhail Gilmutdinov. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController {
    
    @IBOutlet weak var tbItem: UITabBarItem!
    @IBOutlet weak var signOut: UIButton!

    @IBAction func signOutClicked(sender: AnyObject) {
        self.performSegueWithIdentifier("sign out", sender: nil)
    }
    
    override func awakeFromNib() {
        tbItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Lato", size: 20)!, NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        tbItem.titlePositionAdjustment = UIOffsetMake(0, -12)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

