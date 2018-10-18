//
//  AppDelegate.swift
//  GFXSwitcher
//
//  Created by Robert Hilton on 10/17/18.
//  Copyright © 2018 RMRF Robotics. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var statusMenuController: StatusMenuController!
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
		
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
		statusMenuController!.closeService()
	}
	
}

