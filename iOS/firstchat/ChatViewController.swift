//
//  ChatViewController.swift
//  firstchat
//
//  Created by Mikhail Gilmutdinov on 05.03.16.
//  Copyright © 2016 Mikhail Gilmutdinov. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var message: RSKGrowingTextView!
    
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet weak var keyboardHeight1: NSLayoutConstraint!
    @IBOutlet weak var keyboardHeight2: NSLayoutConstraint!
    @IBOutlet weak var keyboardHeight3: NSLayoutConstraint!
    
    override func awakeFromNib() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name:UIKeyboardWillHideNotification, object: nil);
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        message.heightChangeAnimationDuration = 0.1
        if let _ = chat {
            titleLabel.text = String(format: "%@ %@", chat!["name"] as! String, chat!["surname"] as! String)
            photoView.image = chat!["photo"] as? UIImage
        }
    }
    
    internal var chat: [String: NSObject]?
    
    @IBAction func sendPressed(sender: AnyObject) {
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
    
}

