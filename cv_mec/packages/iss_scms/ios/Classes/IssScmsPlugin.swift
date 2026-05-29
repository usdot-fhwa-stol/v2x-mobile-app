import Flutter
import UIKit
import TrafficAuthSDK
// import Algorithms
// import TrafficAuthV2XClient

public class IssScmsPlugin: NSObject, FlutterPlugin {

  var localSigning: LocalSigning?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "iss_scms", binaryMessenger: registrar.messenger())
    let instance = IssScmsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func getNameForValidateStatus(status: ValidateStatus) -> String {
    switch status {
      case .FAILURE:
        return "FAILURE"
      case .NOT_SIGNED:
        return "NOT_SIGNED"
      case .UNKNOWN_CERT:
        return "UNKNOWN_CERT"
      case .UNRECOGNIZED_ISSUER:
        return "UNRECOGNIZED_ISSUER"
      case .VALID:
        return "VALID"
    }
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "getPlatformVersion":
        result("iOS " + UIDevice.current.systemVersion)
      case "init":
        localSigning = LocalSigning.init(scmsEnv: ScmsEnvironment.PREPRODUCTION)
        result(nil)
      case "validate":
        if let signer = localSigning {
          if let args = call.arguments as? Dictionary<String, Any>{
            let message = args["message"] as! FlutterStandardTypedData
            do{
              let (valid, _) = try signer.validate(message:message.data, shouldValidate:true)
              result(getNameForValidateStatus(status:valid))
            } catch{
              result(getNameForValidateStatus(status:ValidateStatus.FAILURE))
            }
          }else{
            result(getNameForValidateStatus(status:ValidateStatus.FAILURE))
          }
        }else{
          result(getNameForValidateStatus(status:ValidateStatus.FAILURE))
        }
      case "sign":
        if let args = call.arguments as? Dictionary<String, Any>{
          if let signer = localSigning {
            let state = signer.getState()
            if( state == SigningAPIState.READY){
              let psid = args["psid"] as! Int
              let tbsOer = args["tbsOer"] as! FlutterStandardTypedData
              let jIndex = args["jIndex"] as? Int
              let digestSigner = args["digestSigner"] as? Bool
              do {
                  
                  
                let outputArray = try signer.sign(psid: psid, tbsOer: tbsOer.data)
                result(outputArray)
              } catch {
                print("❌ Error getting device certs: \(error)")
                result(nil)
              }
            }else{
              result(nil)
            }
          } else {
            result(nil)
          }
        }
      case "getDeviceCerts":
        if let args = call.arguments as? Dictionary<String, Any>{
          let token = args["token"] as? String ?? ""
          let deviceId = args["deviceId"] as? String ?? ""
          var tokenType = TokenType.APP;

          if let signer = localSigning {
            if((args["tokenType"] as? Int ?? 0) != 0){
              tokenType = TokenType.DM_DASHBOARD;
            }
            Task {
              do {
                  if(signer.getState() == SigningAPIState.READY){
                    result(nil)
                  }else{
                    let certs = try await signer.getDeviceCerts(token: token, type: tokenType, deviceId: deviceId)
                    result(nil)
                  }
              } catch {
                  print("❌ Error getting device certs: \(error)")
                  result(nil)
              }
            }
          }
        }else{
          result(nil)
        }
        
      case "getState":
      if let signer = localSigning {
        result(signer.getState().rawValue)
      }else{
        result(SigningAPIState.NEED_CERTS.rawValue)
      }
      case "topOffCerts":
        result("")
      default:
        result(FlutterMethodNotImplemented)
    }
  }
}
