//
//  Connection.swift
//  firstchat
//
//  Created by Mikhail Gilmutdinov on 27.02.16.
//  Copyright © 2016 Mikhail Gilmutdinov. All rights reserved.
//

import Foundation
import UIKit
import JDStatusBarNotification

let sharedConnection = Connection()

public class Connection {
    
    private var userEmail: String?
    private var correctPasscode: String?
    
    public func isRegistered(email: String) -> Bool {
        userEmail = email
        return registered.contains(email.lowercaseString)
    }
    
    public func sendPasscode() -> Bool {
        correctPasscode = String(arc4random_uniform(1000000))
        JDStatusBarNotification.showWithStatus(correctPasscode, dismissAfter: 5)
        return true
    }
    
    public func checkPasscode(passcode: String) -> Bool {
        return passcode == correctPasscode
    }
    
    public func authorize(email: String, password: String) -> Bool {
        if (email.lowercaseString == "com@mmkg.me" || email == "") {
            return true
        } else {
            return false
        }
    }
    
    public var contacts = [
        [
            "name": "Lorraine",
            "surname": "Douglas",
            "id": "1",
            "username": "lorraine",
            "photo": UIImage(imageLiteral: "lorraine")
        ],
        [
            "name": "Stephen",
            "surname": "Evans",
            "id": "2",
            "username": "stephen",
            "photo": UIImage(imageLiteral: "stephen")
        ]
    ]
    
    public var chats = [
        [
            "name": "Lorraine",
            "surname": "Douglas",
            "id": "1",
            "username": "lorraine",
            "photo": UIImage(imageLiteral: "lorraine"),
            "lastMessage": NSDate.init(timeIntervalSinceNow: NSTimeInterval.init(-20000))
        ],
        [
            "name": "Stephen",
            "surname": "Evans",
            "id": "2",
            "username": "stephen",
            "photo": UIImage(imageLiteral: "stephen"),
            "lastMessage": NSDate.init(timeIntervalSinceNow: NSTimeInterval.init(-30000))
        ]
    ]
    
    private var registered = ["com@mmkg.me", "1"]
}

func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
    let rect = CGRectMake(0, 0, size.width, size.height)
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    color.setFill()
    UIRectFill(rect)
    let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
}