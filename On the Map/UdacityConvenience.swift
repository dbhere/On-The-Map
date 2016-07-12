//
//  UdacityConvenience.swift
//  On the Map
//
//  Created by HhhotDog on 16/7/11.
//  Copyright © 2016年 Alexscott. All rights reserved.
//

import UIKit

extension UdacityClient {
    func creatASession(udacityAccount:[String: AnyObject], completionHandlerForCreateASession:(success: Bool,accountKey: String!, errorString: String?) -> Void){
        let jsonBody = "{\"udacity\": {\"\(JSONBodyKeys.Username)\":\"\(udacityAccount[JSONBodyKeys.Username]!)\", \"\(JSONBodyKeys.Password)\":\"\(udacityAccount[JSONBodyKeys.Password]!)\"}}"
        taskForPostMethod(Methods.Session, httpBody: jsonBody) { (result, error) in
            guard error == nil else{
                completionHandlerForCreateASession(success: false, accountKey: nil,errorString: "Invalid Username or Password.")
                return
            }
            guard let account = result[JSONResponseKeys.Account] as? [String: AnyObject], accountKey = account[JSONResponseKeys.AccountKey] as? String else {
                print("cannot find key: \(JSONResponseKeys.AccountKey) in data: \(result)")
                completionHandlerForCreateASession(success: false, accountKey: nil, errorString: "Invalid Username or Password.")
                return
            }
            completionHandlerForCreateASession(success: true, accountKey: accountKey,errorString: nil)
        }
    }
    
    func getPublicUserData(accountKey: String, completionHandlerForGetPublicUserData:(success: Bool, udacityUser: UdacityUser!, error: NSError?) -> Void){
        let newMethod = subtituteKeyInMethod(Methods.GetUserData, key: URLKeys.UserId, value: accountKey)!
        taskForGetMethod(newMethod) { (result, error) in
            guard error == nil else {
                completionHandlerForGetPublicUserData(success: false, udacityUser: nil, error: error)
                return
            }
            guard let userDict = result[JSONResponseKeys.User] as? [String: AnyObject] else {
                completionHandlerForGetPublicUserData(success: false, udacityUser: nil, error: NSError(domain: "getPublicUserData", code: 1, userInfo: [NSLocalizedDescriptionKey:"cannot find key: \(JSONResponseKeys.User) in data: \(result)"]))
                return
            }
            let user = UdacityUser(dictionary: userDict)
            self.clientUser = user
            completionHandlerForGetPublicUserData(success: true, udacityUser: user, error: nil)
        }
    }
    
    func logOutOfASession(completionHandlerForLogOut:(success: Bool, errorString: String?) -> Void) {
        taskForDeleteMethod(Methods.Session) { (result, error) in
            guard error == nil else {
                completionHandlerForLogOut(success: false, errorString: error!.localizedDescription)
                return
            }
            guard let session = result[JSONResponseKeys.Session] as? [String: AnyObject], _ = session[JSONResponseKeys.Id] as? String else {
                completionHandlerForLogOut(success: false, errorString: "oop!. Cannot log out.")
                return
            }
            completionHandlerForLogOut(success: true, errorString: nil)
        }
    }
}








