//
//  AppDelegate.swift
//  ScreenCap
//
//  Created by Patrick Aubin on 9/26/17.
//  Copyright © 2017 Patrick Aubin. All rights reserved.
//

import Cocoa
import Fabric
import Crashlytics

@NSApplicationMain
@objc public class AppDelegate: NSObject, NSApplicationDelegate {
    
    @objc lazy var videoController:VideoController = {
        let videoController:VideoController = VideoController()
        return videoController
    }()

    @IBOutlet weak var statusMenu: NSMenu!
    // Replace NSVariableStatusItemLength with an integer for a fixed width (in pixels)
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    lazy var videoPlayerWindowController:VideoPlayerWindowController = {

//        NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"Main" bundle:nil]; // get a reference to the storyboard
//        myController = [storyBoard instantiateControllerWithIdentifier:@"secondWindowController"]; // instantiate your window controller
//        [myController showWindow:self];
        
        let storyBoard:NSStoryboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let windowController:VideoPlayerWindowController = storyBoard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "VideoPlayerWindowController")) as! VideoPlayerWindowController
        
        return windowController
    }()
    
    @IBOutlet weak var openPlayer: NSMenuItem!
    
    public func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        Fabric.with([Crashlytics.self])

        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(AppDelegate.update), userInfo: nil, repeats: true)
        //Show statusMenu
        statusItem.menu = statusMenu
        
//        self.videoPlayerWindowController.loadWindow()
//        self.videoPlayerWindowController.window?.makeKeyAndOrderFront(self)
    }

    public func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    public func applicationWillFinishLaunching(_ notification: Notification) {
        //  Converted with Swiftify v1.0.6474 - https://objectivec2swift.com/
        var appleEventManager = NSAppleEventManager.shared()
        // 1
        appleEventManager.setEventHandler(self, andSelector: Selector("handleAppleEvent:withReplyEvent:"), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }

    public func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        self.videoController.pendingURL = filename
        
        self.videoController.rootVC.sbViewGetFileURL(URL(fileURLWithPath: filename))
        self.videoController.mainWindowController.window?.makeKeyAndOrderFront(self)
        
        NSApp.activate(ignoringOtherApps: true)
        return true
    }
    
    func handleAppleEvent(_ event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        var url: String? = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue

        self.videoController.isReady = true
        url = (url as NSString?)?.substring(from: 5)
        
        if (url as NSString?)?.substring(to: 6).isEqual("http//") ?? false {
            url = (url as NSString?)?.substring(from: 6)
        }
        
        if (url == "open_without_gui") {
            return
        }
        
        self.videoController.pendingURL = url
        self.videoController.rootVC.sbViewGetFileURL(URL(string: "http://\(String(describing: url))"))
        
        NSApp.activate(ignoringOtherApps: true)
    }

    @IBAction func openPlayer(_ sender: Any) {
        
    }
    
    public func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        
        let dockMenu: NSMenu? = NSMenu()
//        dockMenu?.addItem(withTitle: NSLocalizedString("Play/Pause", comment: ""),
//                          action: #selector(self.videoController.playOrPause), keyEquivalent: "")
//
//        dockMenu?.addItem(withTitle: NSLocalizedString("Next", comment: ""),
//                          action: #selector(self.videoController.nextVideo), keyEquivalent: "")
        
        return dockMenu
    }

    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }

    @objc func update() {
        // Format the date
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "h:mm:ss"
        
        // Convert date into a string
        let now = dateformatter.string(from: NSDate() as Date)
        
        // Replace the title of the item in the status bar
        statusItem.title = "⏳"+now
    }

}

