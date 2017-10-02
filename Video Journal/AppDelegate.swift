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
import MASPreferences
import TMCache
import Carbon
import AVFoundation

var appDelegate: NSObject?

var statusItem: NSStatusItem!

@NSApplicationMain
@objc public class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var cacheImageMenu: NSMenu!
    @IBOutlet weak var autoUpItem: NSMenuItem!
    @IBOutlet weak var uploadMenuItem: NSMenuItem!
    @IBOutlet weak var cacheImageMenuItem: NSMenuItem!
    
    let pasteboardObserver = PasteboardObserver()
    lazy var preferencesWindowController: NSWindowController = {
        let imageViewController = ImagePreferencesViewController()
        let generalViewController = GeneralViewController()
        let controllers = [imageViewController]
        let wc = MASPreferencesWindowController(viewControllers: controllers, title: "Video Journal Settings")
        imageViewController.window = wc.window
        return wc
    }()
    
    @objc lazy var videoController:VideoController = {
        let videoController:VideoController = VideoController()
        return videoController
    }()
    
    @IBOutlet weak var audioDevices: NSMenuItem!
    @IBOutlet weak var screenCapButton: NSMenuItem!
    
    var fileOutput:URL!
    
    @IBOutlet weak var recordMenuItem: NSMenuItem!
    
    var recorder:Recorder!

    @IBOutlet weak var statusMenu: NSMenu!
    
    // Replace NSVariableStatusItemLength with an integer for a fixed width (in pixels)
//    var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    lazy var videoPlayerWindowController:VideoPlayerWindowController = {
        let storyBoard:NSStoryboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let windowController:VideoPlayerWindowController = storyBoard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "VideoPlayerWindowController")) as! VideoPlayerWindowController
        
        return windowController
    }()
    
    lazy var browser:MiniBrowserWindowController = {
        return MiniBrowserWindowController()
    }()
    
    @IBOutlet weak var openPlayer: NSMenuItem!
    
    public func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        Fabric.with([Crashlytics.self])

//        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(AppDelegate.update), userInfo: nil, repeats: true)
        
        registerHotKeys()
        initApp()
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
    
    func initApp()  {
        
        pasteboardObserver.addSubscriber(self)
        
        if AppCache.shared.appConfig.autoUp {
            pasteboardObserver.startObserving()
            autoUpItem.state = NSControl.StateValue(rawValue: 1)
        }
        
        appDelegate = self
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        let statusBarButton = DragDestinationView(frame: (statusItem.button?.bounds)!)
        statusItem.button?.superview?.addSubview(statusBarButton, positioned: .below, relativeTo: statusItem.button)
        let iconImage = NSImage(named: NSImage.Name(rawValue: "StatusIcon"))
        iconImage?.isTemplate = true
        statusItem.button?.image = iconImage
        statusItem.button?.action = #selector(showMenu)
        statusItem.button?.target = self
        
        //Show statusMenu
        statusItem.menu = statusMenu
        
        let submenu:NSMenu = NSMenu()
        
        for (i, device) in DeviceList.audio().enumerated() {
            var menuItem:NSMenuItem!
            
            if i == 0 {
                menuItem = NSMenuItem(title: device["name"]!, action: #selector(changeAudio), keyEquivalent: device["name"]!)
                menuItem.state = .on
            }

            submenu.addItem(menuItem)
        }
        
        self.audioDevices.submenu = submenu
    }

    @IBAction func showHistory(_ sender: Any) {
        self.videoController.mainWindowController = self.videoPlayerWindowController;
        self.videoController.mainWindowController.window?.makeKeyAndOrderFront(self)
    }
    
    @IBAction func record(_ sender: Any) {
        print("record")
        print("clicked")
        
        guard self.recorder != nil && self.recorder.isRecording else {
            self.fileOutput = self.temporaryFile()
            self.recorder = try! Recorder(destination: self.fileOutput,
                                 fps: 30,
                                 cropRect: NSScreen.main!.frame,
                                 showCursor: true,
                                 highlightClicks: true)
            
            self.recorder.start()
            self.recordMenuItem.title = "Recording..."
            self.audioDevices.isEnabled = false
            print("started")
            return
        }
        
        print("stopped")
        self.recordMenuItem.title = "Record"
        self.recorder.stop()
        
        self.audioDevices.isEnabled = true
        
        self.videoController.mainWindowController = self.videoPlayerWindowController;
        SBApplication.share().filePaths = [self.fileOutput.absoluteString]
        (self.videoPlayerWindowController.contentViewController as! VideoPlayerViewController).sbViewGetFileURL((self.fileOutput as NSURL) as URL!)
        (self.videoPlayerWindowController.contentViewController as! VideoPlayerViewController).playlistDataAddToDatabase()
        
        self.videoController.mainWindowController.window?.makeKeyAndOrderFront(self)
        
        print("\(self.fileOutput)")
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
    
    @objc func changeAudio(sender: NSMenuItem) {
        for menuItem:NSMenuItem in (self.audioDevices.submenu?.items)! {
            menuItem.state = .off
        }
        
        for device in DeviceList.audio() {
            if device["name"] == sender.title {
                let audioDevice:[AVCaptureDevice] = AVCaptureDevice.devices(for: .audio).filter {
                    if ($0.localizedName == device["name"]) {
                        return true
                    }
                    
                    return false
                }
                
                self.fileOutput = self.temporaryFile()
                self.recorder = try! Recorder(destination: self.fileOutput, fps: 30,
                                         cropRect: NSScreen.main?.frame,
                                         showCursor: true,
                                         highlightClicks: true,
                                         audioDevice: audioDevice.first)
            }
        }
        

    }
    
    func temporaryFile() -> URL {
        var paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.downloadsDirectory,
                                                        FileManager.SearchPathDomainMask.userDomainMask, true)
        
        let datetime:Int = Int(Date.timeIntervalSinceReferenceDate)
        return URL(fileURLWithPath: paths.first!).appendingPathComponent("vj_\(datetime).mp4")
    }
    
    @objc func showMenu() {
        let pboard = NSPasteboard.general
        if #available(OSX 10.13, *) {
            let files: NSArray? = pboard.propertyList(forType: NSPasteboard.PasteboardType.fileURL) as? NSArray
            if let files = files {
                let i = NSImage(contentsOfFile: files.firstObject as! String)
                i?.scalingImage()
                uploadMenuItem.image = i
            } else {
                let i = NSImage(pasteboard: pboard)
                i?.scalingImage()
                uploadMenuItem.image = i
            }
            let object = TMCache.shared().object(forKey: "imageCache")
            if let obj = object as? [[String: AnyObject]] {
                AppCache.shared.imagesCacheArr = obj
            }
            cacheImageMenuItem.submenu = makeCacheImageMenu(AppCache.shared.imagesCacheArr)
            statusItem.popUpMenu(statusMenu)
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction func statusMenuClicked(_ sender: NSMenuItem) {
        switch sender.tag {
        // 上传
        case 1:
            let pboard = NSPasteboard.general
            ImageService.shared.uploadImg(pboard)
        // 设置
        case 2:
            preferencesWindowController.showWindow(nil)
            preferencesWindowController.window?.center()
            NSApp.activate(ignoringOtherApps: true)
        case 3:
            // 退出
            NSApp.terminate(nil)
        //帮助
        case 4:
            NSWorkspace.shared.open(URL(string: "http://lzqup.com")!)
        case 5:
            break
        //自动上传
        case 6:
            sender.state = NSControl.StateValue(rawValue: 1 - sender.state.rawValue);
            AppCache.shared.appConfig.autoUp =  sender.state.rawValue == 1 ? true : false
            AppCache.shared.appConfig.autoUp ? pasteboardObserver.startObserving() : pasteboardObserver.stopObserving()
            AppCache.shared.appConfig.setInCache("appConfig")
        //切换markdown
        case 7:
            sender.state = NSControl.StateValue(rawValue: 1 - sender.state.rawValue)
            AppCache.shared.appConfig.linkType = LinkType(rawValue: sender.state.rawValue)!
            guard let imagesCache = AppCache.shared.imagesCacheArr.last else {
                return
            }
            let picUrl = imagesCache["url"] as! String
            NSPasteboard.general.setString(LinkType.getLink(path: picUrl, type: AppCache.shared.appConfig.linkType), forType: NSPasteboard.PasteboardType.string)
            AppCache.shared.appConfig.setInCache("appConfig")
        default:
            break
        }
        
    }
    
    @IBAction func btnClick(_ sender: NSButton) {
        switch sender.tag {
        case 1:
            NSWorkspace.shared.open(URL(string: "http://blog.lzqup.com/tools/2016/07/10/Tools-UPImage.html")!)
            self.window.close()
        case 2:
            self.window.close()
            
        default:
            break
        }
    }
    
    func makeCacheImageMenu(_ imagesArr: [[String: AnyObject]]) -> NSMenu {
        let menu = NSMenu()
        if imagesArr.count == 0 {
            let item = NSMenuItem(title: "没有历史", action: nil, keyEquivalent: "")
            menu.addItem(item)
        } else {
            for index in 0..<imagesArr.count {
                let item = NSMenuItem(title: "", action: #selector(cacheImageClick(_:)), keyEquivalent: "")
                item.tag = index
                let i = imagesArr[index]["image"] as? NSImage
                i?.scalingImage()
                item.image = i
                menu.insertItem(item, at: 0)
            }
        }
        
        return menu
    }
    
    @objc func cacheImageClick(_ sender: NSMenuItem) {
        NSPasteboard.general.clearContents()
        let picUrl = AppCache.shared.imagesCacheArr[sender.tag]["url"] as! String
        NSPasteboard.general.setString(LinkType.getLink(path: picUrl, type: AppCache.shared.appConfig.linkType), forType: NSPasteboard.PasteboardType.string)
        NotificationMessage("Image link is successful!", isSuccess: true)
    }
    
}



extension AppDelegate: NSUserNotificationCenterDelegate, PasteboardObserverSubscriber {
    // 强行通知
    public func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        
    }
    
    func pasteboardChanged(_ pasteboard: NSPasteboard) {
        ImageService.shared.uploadImg(pasteboard)
    }
    
    func registerHotKeys() {
        
        var gMyHotKeyRef: EventHotKeyRef? = nil
        var gMyHotKeyIDU = EventHotKeyID()
        var gMyHotKeyIDM = EventHotKeyID()
        var eventType = EventTypeSpec()
        
        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = OSType(kEventHotKeyPressed)
        gMyHotKeyIDU.signature = OSType(32)
        gMyHotKeyIDU.id = UInt32(kVK_ANSI_U);
        gMyHotKeyIDM.signature = OSType(46);
        gMyHotKeyIDM.id = UInt32(kVK_ANSI_M);
        
        RegisterEventHotKey(UInt32(kVK_ANSI_U), UInt32(cmdKey), gMyHotKeyIDU, GetApplicationEventTarget(), 0, &gMyHotKeyRef)
        
        RegisterEventHotKey(UInt32(kVK_ANSI_M), UInt32(controlKey), gMyHotKeyIDM, GetApplicationEventTarget(), 0, &gMyHotKeyRef)
        
        // Install handler.
        InstallEventHandler(GetApplicationEventTarget(), { (nextHanlder, theEvent, userData) -> OSStatus in
            var hkCom = EventHotKeyID()
            GetEventParameter(theEvent, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hkCom)
            switch hkCom.id {
            case UInt32(kVK_ANSI_U):
                let pboard = NSPasteboard.general
                ImageService.shared.uploadImg(pboard)
            case UInt32(kVK_ANSI_M):
                
                AppCache.shared.appConfig.linkType = LinkType(rawValue: 1 - AppCache.shared.appConfig.linkType.rawValue)!
                print(AppCache.shared.appConfig.linkType.rawValue)

                guard let imagesCache = AppCache.shared.imagesCacheArr.last else {
                    return 33
                }
                NSPasteboard.general.clearContents()
                let picUrl = imagesCache["url"] as! String
                NSPasteboard.general.setString(LinkType.getLink(path: picUrl, type: AppCache.shared.appConfig.linkType), forType:NSPasteboard.PasteboardType.string)
                
                
            default:
                break
            }
            
            return 33
            /// Check that hkCom in indeed your hotkey ID and handle it.
        }, 1, &eventType, nil, nil)
        
    }
    
}
