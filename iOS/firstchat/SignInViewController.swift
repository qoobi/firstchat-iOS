//
//  SecondViewController.swift
//  firstchat
//
//  Created by Mikhail Gilmutdinov on 26.02.16.
//  Copyright © 2016 Mikhail Gilmutdinov. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    @IBOutlet weak var keyboardHeight: NSLayoutConstraint!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBAction func proceed(sender: AnyObject) {
        if (sharedConnection.authorize(emailTextField.text!, password: "")) {
            self.performSegueWithIdentifier("logged in", sender: nil)
        } else {
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.07
            animation.repeatCount = 3
            animation.autoreverses = true
            animation.fromValue = NSValue(CGPoint: CGPointMake(emailTextField.center.x - 5, emailTextField.center.y))
            animation.toValue = NSValue(CGPoint: CGPointMake(emailTextField.center.x + 5, emailTextField.center.y))
            emailTextField.layer.addAnimation(animation, forKey: "position")
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
    
    
    /*func displaSigninView () {
        self.signinEmailTextField.text = nil
        self.signinPasswordTextField.text = nil
        
        if self.signupNameTextField.isFirstResponder() {
            self.signupNameTextField.resignFirstResponder()
        }
        
        if self.signupEmailTextField.isFirstResponder() {
            self.signupEmailTextField.resignFirstResponder()
        }
        
        if self.signupPasswordTextField.isFirstResponder() {
            self.signupPasswordTextField.resignFirstResponder()
        }
        
        if self.signinBackgroundView.frame.origin.x != 0 {
            UIView.animateWithDuration(0.8, animations: { () -> Void in
                self.signupBackgroundView.frame = CGRectMake(320, 134, 320, 284)
                self.signinBackgroundView.alpha = 0.3
                
                self.signinBackgroundView.frame = CGRectMake(0, 134, 320, 284)
                self.signinBackgroundView.alpha = 1.0
                }, completion: nil)
        }
    }
    
    func displaySignupView () {
        self.signupNameTextField.text = nil
        self.signupEmailTextField.text = nil
        self.signupPasswordTextField.text = nil
        
        if self.signinEmailTextField.isFirstResponder() {
            self.signinEmailTextField.resignFirstResponder()
        }
        
        if self.signinPasswordTextField.isFirstResponder() {
            self.signinPasswordTextField.resignFirstResponder()
        }
        
        if self.signupBackgroundView.frame.origin.x != 0 {
            UIView.animateWithDuration(0.8, animations: { () -> Void in
                self.signinBackgroundView.frame = CGRectMake(-320, 134, 320, 284)
                self.signinBackgroundView.alpha = 0.3;
                
                self.signupBackgroundView.frame = CGRectMake(0, 134, 320, 284)
                self.signupBackgroundView.alpha = 1.0
                
                }, completion: nil)
        }
    }
    
    func displayAlertMessage(alertTitle:String, alertDescription:String) -> Void {
        // hide activityIndicator view and display alert message
        self.activityIndicatorView.hidden = true
        let errorAlert = UIAlertView(title:alertTitle, message:alertDescription, delegate:nil, cancelButtonTitle:"OK")
        errorAlert.show()
    }
    
    @IBAction func createAccountBtnTapped(sender: AnyObject) {
        self.displaySignupView()
    }
    
    @IBAction func cancelBtnTapped(sender: AnyObject) {
        self.displaSigninView()
    }
    
    
    @IBAction func signupBtnTapped(sender: AnyObject) {
        // Code to hide the keyboards for text fields
        if self.signupNameTextField.isFirstResponder() {
            self.signupNameTextField.resignFirstResponder()
        }
        
        if self.signupEmailTextField.isFirstResponder() {
            self.signupEmailTextField.resignFirstResponder()
        }
        
        if self.signupPasswordTextField.isFirstResponder() {
            self.signupPasswordTextField.resignFirstResponder()
        }
    }
    
    @IBAction func signinBtnTapped(sender: AnyObject) {
        // resign the keyboard for text fields
        if self.signinEmailTextField.isFirstResponder() {
            self.signinEmailTextField.resignFirstResponder()
        }
        
        if self.signinPasswordTextField.isFirstResponder() {
            self.signinPasswordTextField.resignFirstResponder()
        }
    }
    
    func updateUserLoggedInFlag() {
    }
    
    func saveApiTokenInKeychain(tokenDict:NSDictionary) {
    }
    
    func makeSignUpRequest(userName:String, userEmail:String, userPassword:String) {
    }
    
    func makeSignInRequest(userEmail:String, userPassword:String) {   
    }*/
}
