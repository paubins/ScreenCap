//
//  ViewController.swift
//  ScreenCap
//
//  Created by Patrick Aubin on 9/26/17.
//  Copyright © 2017 Patrick Aubin. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var recordButton: NSButton!
    
    var fileOutput:URL!
    
    @IBOutlet weak var deviceMenu: NSPopUpButton!
    @IBOutlet weak var iosDevices: NSPopUpButton!
    
    lazy var recorder:Recorder = {
        self.fileOutput = self.temporaryFile()
        return try! Recorder(destination: self.fileOutput,
                                         fps: 30,
                                         cropRect: NSScreen.main!.frame,
                                         showCursor: true,
                                         highlightClicks: true)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.deviceMenu.removeAllItems()
        
        for device in DeviceList.audio() {
            self.deviceMenu.addItem(withTitle: device["name"]!)
        }
        
        self.deviceMenu.sizeToFit()
    }

    @IBAction func clickedButton(_ sender: Any) {
        print("clicked")
        guard self.recorder.isRecording else {
            self.recorder.start()
            print("started")
            return
        }
        
        print("stopped")
        self.recorder.stop()
        
        let delegate:AppDelegate = NSApp.delegate as! AppDelegate
        
//        delegate.videoController.pendingURL = self.fileOutput.absoluteString
//        delegate.videoController.rootVC.sbViewGetFileURL(self.fileOutput)
        (delegate.videoPlayerWindowController.contentViewController as! VideoPlayerViewController).sbViewGetFileURL(self.fileOutput)
        delegate.videoController.mainWindowController.window?.makeKeyAndOrderFront(self)
        
        
        
        print("\(self.fileOutput)")
    }
    
    @IBAction func deviceSelected(_ sender: Any) {
        
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func temporaryFile() -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
    }
}

