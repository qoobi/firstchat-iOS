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
import SwiftWebSocket
import SwiftKeychainWrapper

let sharedConnection = Connection()

enum Direction:UInt8 {
    case Incoming = 0,
    Outgoing
}

public class Message {
    internal var text: String?
    internal var direction: Direction?
    internal var timestamp: NSDate?
    
    init(text: String, direction: Direction = .Outgoing, timestamp: NSDate = NSDate()) {
        self.text      = text
        self.direction = direction
        self.timestamp = timestamp
    }
}

enum msgType: UInt8 {
    case NO_TYPE = 0,
    OK,
    NOT_OK,
    APP_ID,
    APP_ID_KEY,
    EMAIL,
    CHECK_CODE,
    KEY,
    GET_CONTACTS,
    CONTACT,
    ADD_FRIEND,
    MESSAGE,
    DH_PARAM,
    DH_PUB_KEY
}

public class Connection {
    
    private var userEmail: String?
    private var correctPasscode: String?
    private let ws = WebSocket("wss://firstchat.mmkg.me:12341")
    private var lastSent: msgType? = nil
    private var okChanged: ((Bool?) -> Void)?
    private var ok: Bool? = nil {
        didSet {
            okChanged?(self.ok)
        }
    }
    internal var currentViewController: UIViewController? {
        didSet {
            /*if self.currentViewController is ChatViewController {
                let vc = (self.currentViewController as! ChatViewController)
                var id = UInt64(vc.contact!["id"]!  as! String)!
                if !KeychainWrapper.hasValueForKey("\(id)-key") {
                    self.dhs[id] = DH_generate_parameters(256, 2, nil, nil)
                    let dh = self.dhs[id]!
                    var data = NSMutableData(bytes: &id, length: sizeofValue(id))
                    data.appendBytes(dh.memory.p.memory.d,      length: 4)
                    data.appendBytes(&dh.memory.p.memory.top,   length: 4)
                    data.appendBytes(&dh.memory.p.memory.dmax,  length: 4)
                    data.appendBytes(&dh.memory.p.memory.neg,   length: 4)
                    data.appendBytes(&dh.memory.p.memory.flags, length: 4)
                    
                    data.appendBytes(dh.memory.g.memory.d,      length: 4)
                    data.appendBytes(&dh.memory.g.memory.top,   length: 4)
                    data.appendBytes(&dh.memory.g.memory.dmax,  length: 4)
                    data.appendBytes(&dh.memory.g.memory.neg,   length: 4)
                    data.appendBytes(&dh.memory.g.memory.flags, length: 4)
                    self.sendMessageOfType(.DH_PARAM, withContents: data)
                    NSLog("1")
                    DH_generate_key(dh)
                    
                    data = NSMutableData(bytes: &id, length: sizeofValue(id))
                    data.appendBytes(dh.memory.pub_key.memory.d,      length: 4)
                    data.appendBytes(&dh.memory.pub_key.memory.top,   length: 4)
                    data.appendBytes(&dh.memory.pub_key.memory.dmax,  length: 4)
                    data.appendBytes(&dh.memory.pub_key.memory.neg,   length: 4)
                    data.appendBytes(&dh.memory.pub_key.memory.flags, length: 4)
                    self.sendMessageOfType(.DH_PUB_KEY, withContents: data)
                }
            }*/
        }
    }
    private var firstViewController: FirstViewController?
    
    public var authorized: Bool = false {
        didSet {
            let auth = self.authorized
            JDStatusBarNotification.showWithStatus("auth \(auth)", dismissAfter: 5)
            if auth == true {
                if let vc = currentViewController {
                    if vc is SignInViewController {
                        vc.performSegueWithIdentifier("logged in", sender: nil)
                    }
                }
            }
        }
    }
    
    public func isOk() -> Bool? {
        return self.ok
    }
    
    init () {
        ws.allowSelfSignedSSL = true
        ws.binaryType = .NSData
        ws.event.open = {
            if self.currentViewController == nil || self.currentViewController is SignInViewController {
                var vendorId = UIDevice.currentDevice().identifierForVendor
                let data = NSMutableData(bytes: &vendorId, length: sizeofValue(vendorId))
                if let appkey = KeychainWrapper.dataForKey("appKey") {
                    data.appendData(appkey)
                    self.okChanged = { okay in
                        if let o = okay {
                            if o == true {
                                self.authorized = true
                            }
                        }
                    }
                    self.sendMessageOfType(.APP_ID_KEY, withContents: data)
                } else {
                    self.okChanged = { okay in
                    }
                    self.sendMessageOfType(.APP_ID, withContents: data)
                }
            }
        }
        ws.event.close = { code, reason, clean in
            NSLog("close")
            if let vc = self.currentViewController {
                if vc is SignInViewController && (vc as! SignInViewController).step == 1 {
                } else {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let sivc = storyboard.instantiateViewControllerWithIdentifier("SignInViewController")
                    vc.presentViewController(sivc, animated: true, completion: nil)
                }
            }
            self.ws.open()
            //JDStatusBarNotification.showWithStatus("close", dismissAfter: 5)
        }
        ws.event.error = { error in
            NSLog("error \(error)")
            self.ws.open()
            //JDStatusBarNotification.showWithStatus("error \(error)", dismissAfter: 5)
        }
        ws.event.message = { message in
            if let data = message as? NSData {
                let dataSize = sizeofValue(data)
                if dataSize < sizeof(msgType) {
                    self.ws.close()
                }
                var messageType: msgType = .NO_TYPE
                data.getBytes(&messageType, range: NSRange(location: 0, length: sizeof(msgType)))
                //JDStatusBarNotification.showWithStatus("\(messageType)", dismissAfter: 5)
                switch messageType {
                case .OK:
                    self.ok = true
                case .NOT_OK:
                    self.ok = false
                case .KEY:
                    KeychainWrapper.setData(data.subdataWithRange(NSRange(location: sizeof(msgType), length: data.length - sizeof(msgType))), forKey: "appKey")
                case .CONTACT:
                    var contactId: UInt64 = 0
                    data.getBytes(&contactId, range: NSRange(location: sizeof(msgType), length: 8))
                    //JDStatusBarNotification.showWithStatus("\(data.length)", dismissAfter: 5)
                    let subdata = data.subdataWithRange(NSRange(location: sizeof(msgType) + 8, length: data.length - sizeof(msgType) - 8))
                    let contactEmail = String(data: subdata, encoding: NSUTF8StringEncoding)
                    //data.getBytes(&contactEmail, range: NSRange(location: sizeof(msgType) + 8, length: sizeofValue(data) - sizeof(msgType) - 8))
                    let contact = ["email": contactEmail!, "id": "\(contactId)"]
                    self.contacts.append(contact)
                    self.firstViewController?.tableView.reloadData()
                case .MESSAGE:
                    var fromId: UInt64 = 0
                    data.getBytes(&fromId, range: NSRange(location: sizeof(msgType), length: 8))
                    let subdata = data.subdataWithRange(NSRange(location: sizeof(msgType) + 8, length: data.length - sizeof(msgType) - 8))
                    let contents = String(data: subdata, encoding: NSUTF8StringEncoding)
                    self.messages[fromId]?.append(Message(text: contents!, direction: .Incoming, timestamp: NSDate()))
                    if self.currentViewController is ChatViewController && (self.currentViewController as! ChatViewController).contact!["id"]! == String(fromId) {
                        (self.currentViewController as! ChatViewController).tableView.reloadData()
                    }
                case .DH_PARAM:
                    var fromId: UInt64 = 0
                    data.getBytes(&fromId, range: NSRange(location: sizeof(msgType), length: 8))
                    if self.dhs[fromId] == nil {
                        self.dhs[fromId] = DH_generate_parameters(256, 2, nil, nil)
                    }
                    let dh: UnsafeMutablePointer<DH> = self.dhs[fromId]!
                
                    var loc: Int = sizeof(msgType) + 8
                    data.getBytes(dh.memory.p.memory.d, range: NSRange(location: loc, length: 4))
                    loc += 4
                    data.getBytes(&dh.memory.p.memory.top, range: NSRange(location: loc, length: 4))
                    loc += 4
                    data.getBytes(&dh.memory.p.memory.dmax, range: NSRange(location: loc, length: 4))
                    loc += 4
                    data.getBytes(&dh.memory.p.memory.neg, range: NSRange(location: loc, length: 4))
                    loc += 4
                    data.getBytes(&dh.memory.p.memory.flags, range: NSRange(location: loc, length: 4))
                    loc += 4
                    
                    data.getBytes(dh.memory.g.memory.d, range: NSRange(location: loc, length: 4))
                    loc += 4
                    data.getBytes(&dh.memory.g.memory.top, range: NSRange(location: loc, length: 4))
                    loc += 4
                    data.getBytes(&dh.memory.g.memory.dmax, range: NSRange(location: loc, length: 4))
                    loc += 4
                    data.getBytes(&dh.memory.g.memory.neg, range: NSRange(location: loc, length: 4))
                    loc += 4
                    data.getBytes(&dh.memory.g.memory.flags, range: NSRange(location: loc, length: 4))
                    loc += 4
                    
                    DH_generate_key(dh)
                    self.dhs[fromId] = dh
                    
                    let data = NSMutableData(bytes: &fromId, length: sizeofValue(fromId))
                    data.appendBytes(dh.memory.pub_key.memory.d,      length: 4)
                    data.appendBytes(&dh.memory.pub_key.memory.top,   length: 4)
                    data.appendBytes(&dh.memory.pub_key.memory.dmax,  length: 4)
                    data.appendBytes(&dh.memory.pub_key.memory.neg,   length: 4)
                    data.appendBytes(&dh.memory.pub_key.memory.flags, length: 4)
                    
                    self.sendMessageOfType(.DH_PUB_KEY, withContents: data)
                    
                case .DH_PUB_KEY:
                    var fromId: UInt64 = 0
                    data.getBytes(&fromId, range: NSRange(location: sizeof(msgType), length: 8))
                    
                    let dh: UnsafeMutablePointer<DH> = self.dhs[fromId]!

                    var pub_key = BIGNUM()
                    var loc: Int = sizeof(msgType) + 8
                    data.getBytes(pub_key.d, range: NSRange(location: loc, length: 4))
                    loc += 4
                    data.getBytes(&pub_key.top, range: NSRange(location: loc, length: 4))
                    loc += 4
                    data.getBytes(&pub_key.dmax, range: NSRange(location: loc, length: 4))
                    loc += 4
                    data.getBytes(&pub_key.neg, range: NSRange(location: loc, length: 4))
                    loc += 4
                    data.getBytes(&pub_key.flags, range: NSRange(location: loc, length: 4))
                    loc += 4
                    var key = [UInt8](count: 32, repeatedValue: 0)
                    DH_compute_key(&key, &pub_key, dh)
                    JDStatusBarNotification.showWithStatus("key: \(key)", dismissAfter: 5)
                default:
                    self.ws.close()
                }
            }
        }
        ws.open()
        
    }
    
    private func sendMessageOfType(messageType: msgType, withContents contents: NSData) -> Bool {
        var mt = messageType
        let data = NSMutableData(bytes: &mt, length: sizeof(msgType))
        data.appendData(contents)
        self.lastSent = mt
        self.ok = nil
        ws.send(data)
        //JDStatusBarNotification.showWithStatus("sent: \(data)", dismissAfter: 5)
        return true
    }
    
    internal func sendPasscode(vc: SignInViewController, _ email: String) {
        self.okChanged = vc.passcodeSent
        self.sendMessageOfType(.EMAIL, withContents: email.dataUsingEncoding(NSUTF8StringEncoding)!)
        
        //JDStatusBarNotification.showWithStatus("\(self.ok)", dismissAfter: 5)
        /*if self.ok != nil {
        } else {
            JDStatusBarNotification.showWithStatus("nil(if)", dismissAfter: 5)
        }*/
        /*while true {
            /*if let ok = self.ok {
                return ok
            }*/
            //JDStatusBarNotification.showWithStatus("nil", dismissAfter: 5)
        }*/
        //return false//self.ok!
    }
    
    internal func checkPasscode(vc: SignInViewController, _ passcode: String) {
        self.okChanged = vc.passcodeChecked
        self.sendMessageOfType(.CHECK_CODE, withContents: passcode.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    private var dhs: [UInt64: UnsafeMutablePointer<DH>] = [:]
    
    public var contacts: [[String: NSObject]] = []
        /*[
            "name": "Mikhail",
            "surname": "Gilmutdinov",
            "id": 0,
            "username": "mmkg",
            "photo": UIImage(imageLiteral: "nophoto")
        ],
        [
            "name": "Lorraine",
            "surname": "Douglas",
            "id": 1,
            "username": "lorraine",
            "photo": UIImage(imageLiteral: "lorraine")
        ],
        [
            "name": "Stephen",
            "surname": "Evans",
            "id": 2,
            "username": "stephen",
            "photo": UIImage(imageLiteral: "stephen")
        ]*/
    
    internal func getContacts(vc: FirstViewController) {
        self.contacts = []
        self.firstViewController = vc
        self.sendMessageOfType(.GET_CONTACTS, withContents: NSData())
    }
    
    internal func addFriend(email: String) {
        self.sendMessageOfType(.ADD_FRIEND, withContents: email.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    private var nextId = 3
    public var newUser: [String: NSObject]? {
        set {
            var newValueMutable = newValue!
            newValueMutable["id"] = nextId
            nextId += 1
            newValueMutable["photo"] = UIImage(imageLiteral: "nophoto")
            contacts.append(newValueMutable)
        }
        get {
            return nil
        }
    }
    
    //public var chats: [[String: NSObject]] = []
    /*
        [
            "name": "Lorraine",
            "surname": "Douglas",
            "id": 1,
            "username": "lorraine",
            "photo": UIImage(imageLiteral: "lorraine"),
            "lastMessage": NSDate.init(timeIntervalSinceNow: NSTimeInterval.init(-2000))
        ],
        [
            "name": "Stephen",
            "surname": "Evans",
            "id": 2,
            "username": "stephen",
            "photo": UIImage(imageLiteral: "stephen"),
            "lastMessage": NSDate.init(timeIntervalSinceNow: NSTimeInterval.init(-3000))
        ]
    */
    
    public var messages: [UInt64: [Message]] = [:] {
        didSet {
            NSLog("\(self.messages)")
        }
    }
    /*1: [
     Message(text: "Hi!", direction: .Outgoing, timestamp: NSDate.init(timeIntervalSinceNow: NSTimeInterval.init(-2500))),
     Message(text: "Nulla venenatis dapibus mi, in tempor nunc accumsan et. Maecenas condimentum, odio in consectetur.", direction: .Incoming, timestamp: NSDate.init(timeIntervalSinceNow: NSTimeInterval.init(-2000))),
     ],
     2: []
     */
    
    public var tables: [UInt64: UITableView] = [:]
    
    public func sendMessage(message: Message, forId id: UInt64) -> Bool {
        /*if !KeychainWrapper.hasValueForKey("\(id)-key") {
            return false
        }*/
        if self.messages[id] == nil {
            messages[id] = []
        }
        self.messages[id]?.append(message)
        NSLog("\(self.messages) \(message) \(id)")
        var toId: UInt64 = id
        let buf = NSMutableData(bytes: &toId, length: 8)
        buf.appendData(message.text!.dataUsingEncoding(NSUTF8StringEncoding)!)
        self.sendMessageOfType(.MESSAGE, withContents: buf)
        return true
    }
    
    private var registered = ["com@mmkg.me", "1"]
}

func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
    let rect = CGRectMake(0, 0, size.width, size.height)
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    color.setFill()
    UIRectFill(rect)
    let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return image
}
