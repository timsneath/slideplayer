// Copyright 2018 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Cocoa

class FlutterWindow: NSWindow {
  
  @IBOutlet weak var flutterViewController: FLEViewController!

  override func awakeFromNib() {
    minSize.width = 400.0
    minSize.height = 400.0
    
    FLEColorPanelPlugin.register(with: flutterViewController)
    FLEFileChooserPlugin.register(with: flutterViewController)
    FLEMenubarPlugin.register(with: flutterViewController)
    RecentFilesPlugin.register(with: flutterViewController)

    let assets = NSURL.fileURL(withPath: "flutter_assets", relativeTo: Bundle.main.resourceURL)
    // Pass through argument zero, since the Flutter engine expects to be processing a full
    // command line string.
    var arguments = [CommandLine.arguments[0]];
#if !DEBUG
    arguments.append("--dart-non-checked-mode");
#endif
    flutterViewController.launchEngine(
      withAssetsPath: assets,
      asHeadless: false,
      commandLineArguments: arguments)

    super.awakeFromNib()
  }
}

class RecentFilesPlugin : NSObject, FLEPlugin {
  private let channel: FLEMethodChannel
  static func register(with registrar: FLEPluginRegistrar) {
  
    let channel = FLEMethodChannel(name: "FlutterSlides:CustomPlugin",
                                   binaryMessenger: registrar.messenger,
                                   codec: FLEJSONMethodCodec.sharedInstance())
    let instance = RecentFilesPlugin(channel: channel)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
  
  init(channel: FLEMethodChannel) {
    self.channel = channel
  }
  
  func handle(_ call: FLEMethodCall, result: @escaping FLEMethodResult) {
    if (call.methodName == "get") {
      let recentFilePath = UserDefaults.standard.string(forKey: "recent")
      result(recentFilePath)
    } else if (call.methodName == "set") {
      if let recentPath = call.arguments as? String {
        UserDefaults.standard.set(recentPath, forKey: "recent")
      }
      result(nil)
    } else {
      result(FLEMethodNotImplemented)
    }
  }
}
