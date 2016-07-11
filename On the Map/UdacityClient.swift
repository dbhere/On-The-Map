//
//  UdacityClient.swift
//  On the Map
//
//  Created by HhhotDog on 16/7/10.
//  Copyright © 2016年 Alexscott. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {
    //MARK: Properties
    var session = NSURLSession.sharedSession()
    //var accountKey:String?
    var clientUser: UdacityUser?
    
    override init(){
        super.init()
    }
    
    //MARK: Tasks
    //Get
    func taskForGetMethod(method: String, completionHandlerForGet:(result: AnyObject!, error: NSError?)-> Void) -> NSURLSessionDataTask {
        let request = NSURLRequest(URL: urlFromComponents(method))
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            self.taskBasicProcess("taskForGetMethod", data: data, response: response, error: error, completionHandler: completionHandlerForGet)
        }
        task.resume()
        return task
    }
    
    //Post
    func taskForPostMethod(method: String, httpBody: String, completionHandlerForPost:(result: AnyObject!, error: NSError?)-> Void) -> NSURLSessionDataTask{
        let request = NSMutableURLRequest(URL: urlFromComponents(method))
        request.HTTPMethod = "POST"
        request.HTTPBody = httpBody.dataUsingEncoding(NSUTF8StringEncoding)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            self.taskBasicProcess("taskForPostMethod", data: data, response: response, error: error, completionHandler: completionHandlerForPost)
        }
        task.resume()
        return task
    }
    
    //Delete
    func taskForDeleteMethod(method: String, completionHandlerForDelete: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: urlFromComponents(method))
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            self.taskBasicProcess("taskForDeleteMethod", data: data, response: response, error: error, completionHandler: completionHandlerForDelete)
        }
        task.resume()
        return task
    }
    
    //MARK: Helpers
    func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("<\(key)>") != nil {
            return method.stringByReplacingOccurrencesOfString("<\(key)>", withString: value)
        }
        return nil
    }
    
    private func urlFromComponents(withPathExtension: String? = nil) -> NSURL{
        let components = NSURLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath + (withPathExtension ?? "")
        return components.URL!
    }
    
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertdata:(result:AnyObject!, error: NSError?)->Void){
        var parsedData: AnyObject!
        do {
            parsedData = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        }catch {
            completionHandlerForConvertdata(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: [NSLocalizedDescriptionKey: "cannot parse JSON data: \(data)"]))
        }
        completionHandlerForConvertdata(result: parsedData, error: nil)
    }
    
    //Task basic steps for check error/responseCode/data
    private func taskBasicProcess(domain: String, data: NSData?, response: NSURLResponse?, error: NSError?, completionHandler:(result: AnyObject!, error: NSError?)-> Void) -> Void {
        func sendError(error: String){
            print(error)
            completionHandler(result: nil, error: NSError(domain: domain, code: 1, userInfo: [NSLocalizedDescriptionKey: error]))
        }
        guard error == nil else {
            sendError(error!.localizedDescription)
            return
        }
        guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
            sendError("statusCode not in 2xx.")
            return
        }
        guard let data = data else {
            sendError("cannot find data.")
            return
        }
        //udacity specile 5 characters to skip
        let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
        self.convertDataWithCompletionHandler(newData, completionHandlerForConvertdata: completionHandler)
    }
    
    //MARK: Shared Instance
    class func sharedInstance() -> UdacityClient {
        struct Singleton{
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}