import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private var statusBarManager: StatusBarManager?
  
  override func applicationDidFinishLaunching(_ aNotification: Notification) {
    super.applicationDidFinishLaunching(aNotification)
  }
  
  func setupMethodChannel(with controller: FlutterViewController) {
    let channel = FlutterMethodChannel(
      name: "gitlab_pipeline_monitor/status_bar",
      binaryMessenger: controller.engine.binaryMessenger
    )
    
    channel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else {
        result(FlutterError(code: "UNAVAILABLE", message: "AppDelegate not available", details: nil))
        return
      }
      
      switch call.method {
      case "initialize":
        self.statusBarManager = StatusBarManager()
        result(nil)
      case "updateIcon":
        if let args = call.arguments as? [String: Any],
           let iconName = args["icon"] as? String,
           let tooltip = args["tooltip"] as? String {
          self.statusBarManager?.updateIcon(iconName: iconName, tooltip: tooltip)
        }
        result(nil)
      case "clear":
        self.statusBarManager?.clearStatus()
        self.statusBarManager = nil
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
  
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
  
  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
  
  override func applicationWillTerminate(_ aNotification: Notification) {
    statusBarManager?.clearStatus()
    super.applicationWillTerminate(aNotification)
  }
}
