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
    let textView = UITextView()
    
    private var step = 1
    
    var registered: Bool?
    var username: String?
    var name: String?
    var surname: String?
    
    @IBAction func proceed(sender: AnyObject) {
        
        if step == 1 {
            if !textField.text!.containsString("@") {
                shakeView(textField)
            } else {
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
                registered = sharedConnection.isRegistered(textField.text!)
                if registered! {
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
            } else if registered! {
                performSegueWithIdentifier("logged in", sender: nil)
            } else {
                textView.text! = "Now choose yourself a memorable username. Other people will use it to find you. You will be able to change it later."
                textField.text = ""
                textField.placeholder = "username here"
                step += 1
            }
        } else if step == 3 {
            // not registered
            if textField.text!.isEmpty {
                shakeView(textField)
                textView.text! = "Now choose yourself a memorable username. Other people will use it to find you. You will be able to change it later. Username cannot be empty."
            } else {
                username = textField.text!
                textView.text! = "Now enter your name and surname. These will be shown to other people."
                textField.text = ""
                textField.placeholder = "name and surname"
                step += 1
            }
        } else if step == 4 {
            if textField.text!.isEmpty {
                shakeView(textField)
                textView.text! = "You may enter your name and surname. These will be shown to other people. Name and surname cannot be empty."
            } else {
                let fullname = textField.text!.characters.split(" ", maxSplit: 1, allowEmptySlices: false).map(String.init)
                name = fullname[0]
                surname = fullname[1]
                sharedConnection.newUser = [
                    "name": name!,
                    "surname": surname!,
                    "username": username!
                ]
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
