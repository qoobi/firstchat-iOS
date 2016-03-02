//
//  TabBarController.swift
//  firstchat
//
//  Created by Mikhail Gilmutdinov on 27.02.16.
//  Copyright © 2016 Mikhail Gilmutdinov. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tabBar.clipsToBounds = true
        let background = getImageWithColor(UIColor(red: 0, green: 85/255.0, blue: 104/255.0, alpha: 1), size: CGSize(width: self.view.frame.width / CGFloat(self.tabBar.items!.count), height: self.view.frame.height))
        UITabBar.appearance().selectionIndicatorImage = background
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}