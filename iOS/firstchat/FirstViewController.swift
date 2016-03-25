//
//  FirstViewController.swift
//  firstchat
//
//  Created by Mikhail Gilmutdinov on 26.02.16.
//  Copyright © 2016 Mikhail Gilmutdinov. All rights reserved.
//

import UIKit

class ContactCell : UITableViewCell {
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var label: UILabel!
    internal var contact: [String: NSObject]? {
        didSet {
            photo!.image = contact!["photo"] as? UIImage
            label!.text = String(format: "%@ %@", contact!["name"] as! String, contact!["surname"] as! String)
            label!.adjustsFontSizeToFitWidth = true
        }
    }
}


class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

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