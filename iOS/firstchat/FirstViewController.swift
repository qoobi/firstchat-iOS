//
//  FirstViewController.swift
//  firstchat
//
//  Created by Mikhail Gilmutdinov on 26.02.16.
//  Copyright © 2016 Mikhail Gilmutdinov. All rights reserved.
//

import UIKit
import JDStatusBarNotification

class ContactCell : UITableViewCell {
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var label: UILabel!
    internal var contact: [String: NSObject]? {
        didSet {
            photo!.image = UIImage(imageLiteral: "nophoto")
            label!.text = String(format: "%@", contact!["email"] as! String)
            label!.adjustsFontSizeToFitWidth = true
        }
    }
}

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tbItem: UITabBarItem!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func longPress(sender: UILongPressGestureRecognizer) {
        let alert = UIAlertController(title: "Enter email address", message: nil, preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler(nil)
        let submitAction = UIAlertAction(title: "Add friend", style: .Default) { [unowned alert] (action: UIAlertAction!) in
            let answer = alert.textFields![0]
            if let email = answer.text {
                sharedConnection.addFriend(email)
            }
        }
        
        alert.addAction(submitAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
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
        sharedConnection.currentViewController = self
        sharedConnection.getContacts(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        (segue.destinationViewController as! ContactViewController).contact = (sender as! ContactCell).contact
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sharedConnection.contacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("contactCell")! as! ContactCell
        cell.contact = sharedConnection.contacts[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("contact detail", sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 66
    }

}