//
//  ChatViewController.swift
//  firstchat
//
//  Created by Mikhail Gilmutdinov on 05.03.16.
//  Copyright © 2016 Mikhail Gilmutdinov. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift

class MessageCell: UITableViewCell {
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var textView: UITextView!
    
    internal var message: Message? {
        didSet {
            textView.backgroundColor = .clearColor()
            textView.text = message!.text!
            
            messageView.backgroundColor = .clearColor()
            messageView.layer.cornerRadius = 10
            messageView.layer.masksToBounds = true
            messageView.layer.borderWidth = 4
            messageView.layer.borderColor = message!.direction! == .Incoming ? UIColor(rgba: "#0066bf").CGColor : UIColor(rgba: "#48bf00").CGColor
        }
    }
}

class ChatViewController: UIViewController, UITextViewDelegate, UITableViewDelegate {
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var message: RSKGrowingTextView!
    @IBOutlet weak var keyboardHeight1: NSLayoutConstraint!
    @IBOutlet weak var keyboardHeight2: NSLayoutConstraint!
    @IBOutlet weak var keyboardHeight3: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    internal var contact: [String: NSObject]?
    
    @IBAction func longPress(sender: AnyObject) {
        self.tableView.reloadData()
    }
    
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func sendPressed(sender: AnyObject) {
        sharedConnection.sendMessage(Message(text: message.text!), forId: UInt64(contact!["id"]! as! String)!)
        message.text! = ""
        self.tableView.reloadData()
    }
    
    override func awakeFromNib() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        message.heightChangeAnimationDuration = 0.1
        titleLabel.text = contact!["email"]! as? String
        photoView.image = UIImage(imageLiteral: "nophoto")
        /*if let _ = chat {
            titleLabel.text = String(format: "%@ %@", chat!["name"] as! String, chat!["surname"] as! String)
            photoView.image = chat!["photo"] as? UIImage
            sharedConnection.tables[chat!["id"] as! Int] = self.tableView
        }*/
    }
    
    func keyboardWillShow(sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            self.keyboardHeight1?.constant = keyboardSize.height
            self.keyboardHeight2?.constant = keyboardSize.height
            self.keyboardHeight3?.constant = keyboardSize.height
            UIView.animateWithDuration(0) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        if let _ = (sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            self.keyboardHeight1?.constant = 0
            self.keyboardHeight2?.constant = 0
            self.keyboardHeight3?.constant = 0
            UIView.animateWithDuration(0) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        sharedConnection.currentViewController = self
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let c = sharedConnection.messages[UInt64(contact!["id"]! as! String)!]?.count {
            return c
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let message = sharedConnection.messages[UInt64(contact!["id"]! as! String)!]?[indexPath.row]
        NSLog("\(UInt64(contact!["id"]! as! String)!)")
        let id = (message?.direction == .Incoming ? "incoming" : "outgoing") + "MessageCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(id)! as! MessageCell
        cell.message = message
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

