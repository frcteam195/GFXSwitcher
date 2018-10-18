//
//  StatusMenuController.swift
//  GFXSwitcher
//
//  Created by Robert Hilton on 10/17/18.
//  Copyright © 2018 RMRF Robotics. All rights reserved.
//

import Cocoa
import ServiceManagement

class StatusMenuController: NSObject {
	let APP_HELPER_BUNDLE_ID = "com.rmrfrobotics.GFXSwitcherHelper" as CFString
	
	
	@IBOutlet weak var statusMenu: NSMenu!
	
	let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
	private var acTimer: RepeatingTimer = RepeatingTimer(timeInterval: 10)
	
	fileprivate static let IOSERVICE_BATTERY = "AppleSmartBattery"
	fileprivate var service: io_service_t = 0
	
	@IBAction func setRunAtStartup(_ sender: NSMenuItem) {
		if (sender.state == NSControl.StateValue.on) {
			sender.state = NSControl.StateValue.off
		} else {
			sender.state = NSControl.StateValue.on
		}
		let autoLaunch = (sender.state == NSControl.StateValue.on)
		
		setRunAtStartup(runAtStartup: autoLaunch)
	}
	
	private func setRunAtStartup(runAtStartup: Bool) {
		if SMLoginItemSetEnabled(APP_HELPER_BUNDLE_ID, runAtStartup) {
			if runAtStartup {
				NSLog("Successfully added login item!")
			} else {
				NSLog("Successfully removed login item!")
			}
			
		} else {
			NSLog("Failed to add login item.")
		}
	}
	
	override func awakeFromNib() {
		let icon = NSImage(named: "gpuIcon")
		icon?.isTemplate = true // best for dark mode
		statusItem.button?.image = icon;
		statusItem.menu = statusMenu
		
		setRunAtStartup(runAtStartup: true)
		setupTimer();
	}
	
	private func setupTimer() {
		acTimer.eventHandler = {
			_ = self.isACPowered()
		}
		
		acTimer.resume()
	}
	
	private func openService() {
		if (service == 0) {
			
			service = IOServiceGetMatchingService(kIOMasterPortDefault,
												  IOServiceNameMatching(StatusMenuController.IOSERVICE_BATTERY))
			
			GSMux.switcherOpen()
			
			if (service == 0) {
				#if DEBUG
					NSLog("Error creating service")
				#endif
			}
		}
	}
	
	private func closeService() {
		IOObjectRelease(service)
		service    = 0     // Reset this incase open() is called again
		GSMux.switcherClose()
	}
	
	public func isACPowered() -> Bool {
		if (service == 0) {
			openService()
		}
		
		let prop = IORegistryEntryCreateCFProperty(service,
												   "ExternalConnected" as CFString,
												   kCFAllocatorDefault, 0)
		
		let acPowered: Bool = prop!.takeUnretainedValue() as! Bool
		
		var result: Bool = false;
		if (acPowered) {
			result = GSMux.setMode(GSSwitcherModeForceDiscrete)
			NSLog("Setting Discrete");
		} else {
			result = GSMux.setMode(GSSwitcherModeDynamicSwitching)
			NSLog("Setting Dynamic");
		}
		
		NSLog("Switching Result: " + BoolToString(b: result))
		NSLog("Discrete: " + BoolToString(b: GSMux.isUsingDiscreteGPU()))
		NSLog("Integrated: " + BoolToString(b: GSMux.isUsingIntegratedGPU()))
		NSLog("Dynamic: " + BoolToString(b: GSMux.isUsingDynamicSwitching()))
		NSLog("\n")

		return acPowered
	}
	
	@IBAction func quitClicked(sender: NSMenuItem) {
		closeService()
		NSApplication.shared.terminate(self)
	}
	
	private func BoolToString(b: Bool?)->String { return b?.description ?? "<None>"}
}
