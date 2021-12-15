//
//  URLManager.swift
//  FMContractorCustomer
//
//  Created by WedoWebApps on 05/02/18.
//  Copyright © 2018 WedoWebApps. All rights reserved.
//

import UIKit
import Alamofire
import SystemConfiguration
import MBProgressHUD
class URLManager: NSObject
{
    
    func URLCall(method: Alamofire.HTTPMethod, parameters:[String:Any],header : HTTPHeaders, url:String,completion: @escaping (_ resultDict: [String:Any],_ status:Bool,_ message:String) -> Void)
        
    {
        let resultDict : [String:Any] = [String:Any]()
        var succmsg : String = ""
        if(!self.isInternetAvailable())
        {
            showAlert(message:"The Internet connection appears to be offline")
            completion(resultDict,false,"The Internet connection appears to be offline")
   
        }
        //headers
//        let authToken = UserDefaults.standard.value(forKey: kAuthToken) as? String ?? ""
//        let header : HTTPHeaders = [
//                  "X-Requested-With" : kHTTPRequest,
//                  "Authorization" : authToken != "" ? "Bearer \(authToken)" : ""
//               ]
        
        AF.request(url, method: method, parameters: parameters, encoding:URLEncoding.default,headers:header).responseJSON{ (response) in
            if response.response?.statusCode == 200
            {
                if let result = response.result as? NSDictionary
                {
                    if let resultDict = (result as! NSDictionary).value(forKey: "data") as? [String:Any]
                    {
                        completion(resultDict,true,(result as! NSDictionary).value(forKey: "message") as? String ?? "")
                    }
                    else
                    {
                        if let msg = (result as! NSDictionary).value(forKey: "message") as? String
                        {
                            completion(resultDict,true,msg)
                        }
                    }
                }
                else
                {
                    completion(resultDict,false,"")
                }
            }
            else
            {
                if let result = response.result as? NSDictionary
                {
                    if var msg = (result as! NSDictionary).value(forKey: "message") as? String
                    {
                        //new code
                        if msg == "Unauthenticated."
                        {
                            msg = "You might have used your login credential into another device.Please login again."
                            completion(resultDict,false,msg)
                        }
                        else
                        {
                            completion(resultDict,false,msg)
                        }
                    }
                    else
                    {
                        completion(resultDict,false,"")
                    }
                }
                else
                {
                    completion(resultDict,false,"")
                }
            }
           
        }
    }

    func showAlert(message:String)
    {
        let alertController = UIAlertController(title: "kAppName", message: message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
            alertController.dismiss(animated: true, completion: nil)
        }
        action1.setValue(UIColor.red, forKey: "titleTextColor")
        alertController.addAction(action1)
        if UIApplication.shared.windows[0].rootViewController != nil
        {
            DispatchQueue.main.async {
                UIApplication.shared.windows[0].rootViewController?.present(alertController, animated: true, completion: nil)
            }
        }

    }
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }

}

