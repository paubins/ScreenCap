//
//  ImagePreferencesViewController.swift
//  imageUpload
//
//  Created by Pro.chen on 16/7/8.
//  Copyright © 2016年 chenxt. All rights reserved.
//

import Cocoa
import MASPreferences
import Alamofire

class ImagePreferencesViewController: NSViewController, MASPreferencesViewController {
	
    @IBOutlet weak var signupLink: NSTextField!
    @IBOutlet weak var logoutButton: NSButton!
    
    var viewIdentifier: String { get { return "image" } }
    
	var toolbarItemLabel: String? { get { return "Settings" } }
    var toolbarItemImage: NSImage? { get { return NSImage(named: NSImage.Name.user) } }
    
	var window: NSWindow?
    
	@IBOutlet weak var accessKeyTextField: NSTextField!
	@IBOutlet weak var secretKeyTextField: NSTextField!
	
	@IBOutlet weak var checkButton: NSButton!
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
        self.setHyperlinkWithTextField()
        
        CookieController.loadCookies()
        
        if (CookieController.isLoggedIn()) {
            let defaults:UserDefaults = UserDefaults.standard
            self.accessKeyTextField.stringValue = defaults.value(forKey: "username") as! String
            self.secretKeyTextField.stringValue = defaults.value(forKey: "password") as! String
        }
        
        self.accessKeyTextField.isEnabled = !CookieController.isLoggedIn()
        self.secretKeyTextField.isEnabled = !CookieController.isLoggedIn()
        self.checkButton.isEnabled = !CookieController.isLoggedIn()
        self.logoutButton.isEnabled = CookieController.isLoggedIn()
	}
    
    func setHyperlinkWithTextField() {
        let string:NSMutableAttributedString = NSMutableAttributedString()
        
        self.signupLink.allowsEditingTextAttributes = true
        self.signupLink.isSelectable = true
        
        let url:URL = URL(string: "http://vidjo.co/signup.php")!
        
        string.append(NSAttributedString.hyperlink(from: "Signup for a free account at Vidjo.co", with: url))
        
        self.signupLink.attributedStringValue = string
    }

	func showAlert(_ message: String, informative: String) {
		let arlert = NSAlert()
		arlert.messageText = message
		arlert.informativeText = informative
		arlert.addButton(withTitle: "Alert")
        arlert.icon = message == "Verification is successful!" ? NSImage(named: NSImage.Name(rawValue: "Icon_32x32")) :  NSImage(named: NSImage.Name(rawValue: "Failure"))
		arlert.beginSheetModal(for: self.window!, completionHandler: { (response) in
			
		})
	}
    
    @IBAction func login(_ sender: Any) {
        self.loginToClipBucket(email: self.accessKeyTextField.stringValue,
                               password: self.secretKeyTextField.stringValue)
    }
    
    @IBAction func logoutButtonClicked(_ sender: Any) {
        self.accessKeyTextField.isEnabled = true
        self.secretKeyTextField.isEnabled = true
        self.checkButton.isEnabled = true
        self.logoutButton.isEnabled = false
        
        NotificationController.notificationMessage("You are logged out!", informative: "You are now logged out!", isSuccess: false)
        
        CookieController.loadCookies()
        CookieController.clearAllCookies()
        CookieController.saveCookies()
    }
    
    func loginToClipBucket(email: String, password: String) {
        MYProgressHUD.showStatus("Logging in...", from: self.window?.contentView)
        
        let parameters = [ "username" : email, "password" : password, "login" : "login" ]
        Alamofire.request("http://vidjo.co/signup.php?mode=login", method: .post, parameters: parameters, encoding: URLEncoding()).response { response in
            print(response.request)
            print(response.response)
            print(response.data)
            print(response.error)
            
            CookieController.saveCookies()
            
            self.accessKeyTextField.isEnabled = false
            self.secretKeyTextField.isEnabled = false
            self.checkButton.isEnabled = false
            self.logoutButton.isEnabled = true
            
            let defaults:UserDefaults = UserDefaults.standard
            defaults.set(email, forKey: "username")
            defaults.set("password", forKey: "password")
            defaults.synchronize()
            
            NotificationController.notificationMessage("Logged in", informative: "You are now logged in!", isSuccess: true)
            
            MYProgressHUD.dismiss()
        }
    }
	
}
