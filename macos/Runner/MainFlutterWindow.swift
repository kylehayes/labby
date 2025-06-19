import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    
    // Set up status bar method channel after plugins are registered
    if let appDelegate = NSApp.delegate as? AppDelegate {
      appDelegate.setupMethodChannel(with: flutterViewController)
    }

    super.awakeFromNib()
  }
}
