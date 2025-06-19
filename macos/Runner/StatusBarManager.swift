import Cocoa
import FlutterMacOS

class StatusBarManager: NSObject {
    private var statusBarItem: NSStatusItem?
    
    override init() {
        super.init()
        setupStatusBar()
    }
    
    private func setupStatusBar() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusBarItem?.button {
            // Use template image that's compatible with macOS 10.15
            if let image = NSImage(named: NSImage.statusAvailableName) {
                button.image = image
            } else {
                // Fallback to a simple circle
                let image = NSImage(size: NSSize(width: 16, height: 16))
                image.lockFocus()
                NSColor.labelColor.setFill()
                let path = NSBezierPath(ovalIn: NSRect(x: 2, y: 2, width: 12, height: 12))
                path.fill()
                image.unlockFocus()
                button.image = image
            }
            button.image?.isTemplate = true
            button.toolTip = "Labby"
            
            // Add click handler to bring app to front
            button.action = #selector(statusBarButtonClicked)
            button.target = self
        }
    }
    
    @objc private func statusBarButtonClicked() {
        NSApp.activate(ignoringOtherApps: true)
        
        // Bring the main window to front
        if let window = NSApp.windows.first {
            window.makeKeyAndOrderFront(nil)
        }
    }
    
    func updateIcon(iconName: String, tooltip: String) {
        DispatchQueue.main.async {
            guard let button = self.statusBarItem?.button else { return }
            
            // Create colored dots to represent status instead of SF Symbols
            let image = NSImage(size: NSSize(width: 16, height: 16))
            image.lockFocus()
            
            // Clear background
            NSColor.clear.setFill()
            NSRect(x: 0, y: 0, width: 16, height: 16).fill()
            
            var fillColor: NSColor
            if iconName.contains("checkmark") {
                fillColor = NSColor.systemGreen
            } else if iconName.contains("xmark") {
                fillColor = NSColor.systemRed
            } else if iconName.contains("arrow.clockwise") {
                fillColor = NSColor.systemBlue
            } else if iconName.contains("exclamationmark") {
                fillColor = NSColor.systemOrange
            } else {
                fillColor = NSColor.systemGray
            }
            
            fillColor.setFill()
            let path = NSBezierPath(ovalIn: NSRect(x: 2, y: 2, width: 12, height: 12))
            path.fill()
            
            image.unlockFocus()
            // DON'T set isTemplate = true so we keep our custom colors
            image.isTemplate = false
            button.image = image
            
            button.toolTip = tooltip
        }
    }
    
    func clearStatus() {
        // Capture the status bar item to avoid accessing self in the async block
        let itemToRemove = self.statusBarItem
        self.statusBarItem = nil
        
        DispatchQueue.main.async {
            if let statusBarItem = itemToRemove {
                NSStatusBar.system.removeStatusItem(statusBarItem)
            }
        }
    }
    
    deinit {
        clearStatus()
    }
}