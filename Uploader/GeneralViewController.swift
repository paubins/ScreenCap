//
//  GeneralViewController.swift
//  U图床
//
//  Created by Pro.chen on 7/18/16.
//  Copyright © 2016 chenxt. All rights reserved.
//

import Cocoa
import MASPreferences


class GeneralViewController: NSViewController, MASPreferencesViewController {
    var viewIdentifier: String { get { return "general" } }
    
	var toolbarItemLabel: String? { get { return "Basic" } }
    var toolbarItemImage: NSImage? { get { return NSImage(named: NSImage.Name.preferencesGeneral) } }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}
	
}
