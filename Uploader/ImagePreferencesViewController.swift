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
	
    var viewIdentifier: String { get { return "image" } }
    
	var toolbarItemLabel: String? { get { return "Settings" } }
    var toolbarItemImage: NSImage? { get { return NSImage(named: NSImage.Name.user) } }
    
	var window: NSWindow?
    
	@IBOutlet weak var accessKeyTextField: NSTextField!
	@IBOutlet weak var secretKeyTextField: NSTextField!
	
	@IBOutlet weak var checkButton: NSButton!
    
	override func viewDidLoad() {
		super.viewDidLoad()
		
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
        self.loginToClipBucket(email: "admin", password: "password")
    }
    
    func loginToClipBucket(email: String, password: String) {
        
        let manager:SessionManager = SessionManager()

        // Add Headers
        manager.session.configuration.httpAdditionalHeaders = [
            "Cookie":"PHPSESSID=bj2kl0qcc4064mbchna2dtb561&pageredir=http%3A%2F%2Fclipbucket2-paubins.c9users.io%2Fupload%2F",
        ]
        
//        // Add parameters
//        let params: [String: String] = [
//            "email": email,
//            "password": password
//        ]
        
        var request = URLRequest(url: URL(string: "http://clipbucket2-paubins.c9users.io/upload/signup.php?mode=login")!)
        request.httpMethod = HTTPMethod.post.rawValue
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
//        request.setValue("Cookie", forHTTPHeaderField: "request_method=POST")
        request.httpBody = "username=\(email)&password=\(password)&login=login".data(using: String.Encoding.utf8)

        let parameters = [ "username" : email, "password" : password, "login" : "login" ]
        Alamofire.request("http://clipbucket2-paubins.c9users.io/upload/signup.php?mode=login", method: .post, parameters: parameters, encoding: URLEncoding()).response { response in
            print(response.request)
            print(response.response)
            print(response.data)
            print(response.error)
        }
        
//        Alamofire.request(request).validate(statusCode: 200..<300).response { (response) in
//            if let
//                headerFields = response.response?.allHeaderFields as? [String: String],
//                let url = response.request?.url
//            {
//                let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url)
//                print(cookies)
//            }
//        }

//        //Fetch Request
//        Alamofire.request(.POST, "http://clipbucket2-paubins.c9users.io/upload/signup.php",
//                          parameters: URLParameters,
//                          encoding: .JSON).validate(statusCode: 200..<300).responseJSON {
//                            (response, error) in
//
//
//        }
    }
	
}
