import Flutter
import UIKit

public class SwiftFlutterBaiduttsPlugin: NSObject, FlutterPlugin {
  var sharedInstance:BDSSpeechSynthesizer?;

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_baidutts", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterBaiduttsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if (call.method == "init") {
        initTts(call, result)
    } else if (call.method == "speak") {
        speak(call, result)
    } else if (call.method == "setVolume") {
        setVolume(call, result)
    } else if (call.method == "pause") {
        pause(call, result)
    } else if (call.method == "resume") {
        resume(call, result)
    } else if (call.method == "stop") {
        stop(call, result)
    }
  }
    
    public func stop(_ call: FlutterMethodCall,_ result: @escaping FlutterResult) {
        sharedInstance?.cancel()
        result(0)
    }
    
    public func resume(_ call: FlutterMethodCall,_ result: @escaping FlutterResult) {
        sharedInstance?.resume()
        result(0)
    }
    
    public func pause(_ call: FlutterMethodCall,_ result: @escaping FlutterResult) {
        sharedInstance?.pause()
        result(0)
    }
    
    public func setVolume(_ call: FlutterMethodCall,_ result: @escaping FlutterResult) {
        let argements = call.arguments as! Dictionary<String, Double>
        let volume = argements["volume"]!
        
        sharedInstance?.setPlayerVolume(Float(volume))
        
        result(0)
    }

    public func initTts(_ call: FlutterMethodCall,_ result: @escaping FlutterResult) {
        let arguments = call.arguments as! Dictionary<String, String>

        let appId = arguments["appId"]
        let apiKey = arguments["appKey"]
        let secretKey = arguments["appSecret"]

        sharedInstance = BDSSpeechSynthesizer.sharedInstance()

        sharedInstance?.setApiKey(apiKey, withSecretKey: secretKey)

        let offlineEngineSpeechData = Bundle.main.path(forResource: "Chinese_And_English_Speech_Female", ofType: "dat")

        let offlineChineseAndEnglishTextData = Bundle.main.path(forResource: "Chinese_And_English_Text", ofType:  "dat")

        let err = sharedInstance?.loadOfflineEngine(offlineChineseAndEnglishTextData, speechDataPath: offlineEngineSpeechData, licenseFilePath: nil, withAppCode: appId)

        result(err == nil ? 0 : -1)
    }

    public func speak(_ call: FlutterMethodCall,_ result: @escaping FlutterResult) {
        let arguments = call.arguments as! Dictionary<String, String>
        let word = arguments["word"]

        let err: ErrorPointer = nil

        sharedInstance?.speakSentence(word, withError: err)

        result(err == nil ? 0 : -1)
    }
}
