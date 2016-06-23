//
//  ContactViewController.swift
//  firstchat
//
//  Created by Mikhail Gilmutdinov on 25.03.16.
//  Copyright © 2016 Mikhail Gilmutdinov. All rights reserved.
//

import UIKit

class ContactViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var photoView: UIImageView!
    
    internal var contact: [String: NSObject]?
    
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func text(sender: AnyObject) {
        performSegueWithIdentifier("to chat window", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        (segue.destinationViewController as! ChatViewController).contact = self.contact
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let _ = contact {
            titleLabel.text = String(format: "%@", contact!["email"] as! String)
            photoView.image = UIImage(imageLiteral: "nophoto")//contact!["photo"] as? UIImage
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
