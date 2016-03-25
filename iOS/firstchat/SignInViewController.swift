//
//  SecondViewController.swift
//  firstchat
//
//  Created by Mikhail Gilmutdinov on 26.02.16.
//  Copyright © 2016 Mikhail Gilmutdinov. All rights reserved.
//

import UIKit
import JDStatusBarNotification

func shakeView(view: UIView) {
    let shake = CABasicAnimation(keyPath: "position")
    shake.duration = 0.07
    shake.repeatCount = 3
    shake.autoreverses = true
    shake.fromValue = NSValue(CGPoint: CGPointMake(view.center.x - 5, view.center.y))
    shake.toValue = NSValue(CGPoint: CGPointMake(view.center.x + 5, view.center.y))
    view.layer.addAnimation(shake, forKey: "position")
}

class SignInViewController: UIViewController {
    
    @IBOutlet weak var logoBottom: NSLayoutConstraint!
    @IBOutlet weak var keyboardHeight: NSLayoutConstraint!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var logo: UIImageView!
    
    private var step = 1
    
    @IBAction func proceed(sender: AnyObject) {
        if step == 1 {
            if !textField.text!.containsString("@") {
                shakeView(textField)
            } else {
                let textView = UITextView()
                textView.translatesAutoresizingMaskIntoConstraints = false
                textView.backgroundColor = .clearColor()
                textView.textColor = .whiteColor()
                textView.font = textField.font?.fontWithSize(20)
                textView.editable = false
                textView.selectable = false
                textView.scrollEnabled = false
                view.addSubview(textView)
                view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(<=20@1000)-[logo]-(==20@1000)-[textView]-(<=20@1000)-[textField]", options: [], metrics: nil, views: ["logo": logo, "textView": textView, "textField": textField]))
                view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(==20)-[textView]-(==20)-|", options: [], metrics: nil, views: ["textView": textView]))
                if logoBottom != nil {
                    view.removeConstraint(logoBottom)
                }
                if sharedConnection.isRegistered(textField.text!) {
                    textView.text! = self.textField.text! + " is already on firstchat. Your chats from other devices cannot be downloaded due to end-to-end encryption.\nTo sign in enter the 6-digit passcode emailed to you."
                } else {
                    textView.text! = "Welcome to firstchat.\nNow enter the 6-digit passcode emailed to " + self.textField.text! + "."
                }
                textField.text = ""
                textField.placeholder = "passcode here"
                sharedConnection.sendPasscode()
                UIView.animateWithDuration(0.5) {
                    self.view.layoutIfNeeded()
                }
                step += 1
            }
        } else if step == 2 {
            if !sharedConnection.checkPasscode(textField.text!) {
                shakeView(textField)
            } else {
                performSegueWithIdentifier("logged in", sender: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name:UIKeyboardWillHideNotification, object: nil);
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func keyboardWillShow(sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            self.keyboardHeight?.constant = 5 + keyboardSize.height
            UIView.animateWithDuration(0) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        if let _ = (sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            self.keyboardHeight?.constant = 5
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
