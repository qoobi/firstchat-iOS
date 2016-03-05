//
//  SecondViewController.swift
//  firstchat
//
//  Created by Mikhail Gilmutdinov on 26.02.16.
//  Copyright © 2016 Mikhail Gilmutdinov. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
}

class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tbItem: UITabBarItem!
    @IBOutlet weak var tableView: UITableView!
    
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sharedConnection.chats.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("chatCell")! as! ChatCell
        let chat = sharedConnection.chats[indexPath.row]
        cell.photo!.image = chat["photo"] as? UIImage
        NSLog(chat["name"] as! String)
        cell.nameLabel!.text = String(format: "%@ %@", chat["name"] as! String, chat["surname"] as! String)
        cell.nameLabel!.adjustsFontSizeToFitWidth = true
        let formatter = NSDateFormatter()
        formatter.dateStyle = .NoStyle
        formatter.timeStyle = .ShortStyle
        let date = chat["lastMessage"] as! NSDate
        cell.timeLabel!.text = formatter.stringFromDate(date)
        cell.nameLabel!.adjustsFontSizeToFitWidth = true
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("to chat window", sender: nil)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88
    }
}

