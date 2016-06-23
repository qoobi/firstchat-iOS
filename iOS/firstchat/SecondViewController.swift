//
//  SecondViewController.swift
//  firstchat
//
//  Created by Mikhail Gilmutdinov on 26.02.16.
//  Copyright © 2016 Mikhail Gilmutdinov. All rights reserved.
//

import UIKit
import DateTools

class ChatCell: UITableViewCell {
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    internal var chatId: UInt64?
    /*
    internal var chat: [String: NSObject]? {
        didSet {
            photo!.image = chat!["photo"] as? UIImage
            nameLabel!.text = String(format: "%@ %@", chat!["name"] as! String, chat!["surname"] as! String)
            nameLabel!.adjustsFontSizeToFitWidth = true
            let date = chat!["lastMessage"] as! NSDate
            timeLabel!.text = date.timeAgoSinceNow()
            timeLabel!.adjustsFontSizeToFitWidth = true
        }
    }*/
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

    override func viewWillAppear(animated: Bool) {
        if let selection = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(selection, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        //(segue.destinationViewController as! ChatViewController).chatId = (sender as! ChatCell).chatId!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0//sharedConnection.chats.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("chatCell")! as! ChatCell
        //cell.chatId = sharedConnection.chats[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("to chat window", sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88
    }
}

