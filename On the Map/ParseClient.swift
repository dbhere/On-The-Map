//
//  ParseClient.swift
//  On the Map
//
//  Created by HhhotDog on 16/7/12.
//  Copyright © 2016年 Alexscott. All rights reserved.
//

import Foundation

class ParseClient: NSObject {
    //MARK: Properties
    var session = NSURLSession.sharedSession()
    var studentLocations: [StudentLocation]!
    
    override init() {
        super.init()
    }
    
    //MARK: Tasks
    //Get
    func taskForGetMethod(method: String, parameters:[String: AnyObject], completionHandlerForGetMethod:(results: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask{
        let request = basicMutableUrlRequest(method, parameters: parameters)
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            self.basicTaskCheckProcess("taskForGetMethod", data: data, response: response, error: error, completionHandler: completionHandlerForGetMethod)
        }
        task.resume()
        return task
    }
    //Post
    func taskForPostMethod(method: String, parameters:[String: AnyObject], jsonBody: String, completionHandlerForPostMethod:(results: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask{
        let request = basicMutableUrlRequest(method, parameters: parameters)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            self.basicTaskCheckProcess("taskForPostMethod", data: data, response: response, error: error, completionHandler: completionHandlerForPostMethod)
        }
        task.resume()
        return task
    }
    //Put
    func taskForPutMethod(method: String, parameters:[String: AnyObject], jsonBody: String, completionHandlerForPutMethod:(results: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask{
        let request = basicMutableUrlRequest(method, parameters: parameters)
        request.HTTPMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            self.basicTaskCheckProcess("taskForPutMethod", data: data, response: response, error: error, completionHandler: completionHandlerForPutMethod)
        }
        task.resume()
        return task
    }
    
    
    //MARK: TaskHelpers
    private func basicMutableUrlRequest(method: String, parameters:[String: AnyObject]) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: parseUrlFromParameters(parameters, withPathExtension: method))
        request.addValue(Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RestApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        return request
    }
    
    private func basicTaskCheckProcess(domain: String,data: NSData?, response: NSURLResponse?, error: NSError?, completionHandler:(results: AnyObject!, error: NSError?) -> Void) {
        func sendError(error: String) {
            print(error)
            completionHandler(results: nil, error: NSError(domain: domain, code: 1, userInfo: [NSLocalizedDescriptionKey: error]))
        }
        
        guard error == nil else{
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
        self.convertDataFromJSON(data
            , completionHandlerForConvertData: completionHandler)
    }
    
    //MARK: - Heplers
    func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("<\(key)>") != nil {
            return method.stringByReplacingOccurrencesOfString("<\(key)>", withString: value)
        }
        return nil
    }
    
    private func parseUrlFromParameters(parameters:[String: AnyObject], withPathExtension: String? = nil) -> NSURL {
        let components  = NSURLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters{
            components.queryItems!.append(NSURLQueryItem(name: key, value: "\(value)"))
        }
        return components.URL!
    }
    
    private func convertDataFromJSON(data: NSData, completionHandlerForConvertData:(results: AnyObject!, error: NSError?) -> Void){
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            completionHandlerForConvertData(results: nil, error: NSError(domain: "convertDataFromJSON", code: 1, userInfo: [NSLocalizedDescriptionKey: "cannot parse JSON data: \(data)"]))
            return
        }
        completionHandlerForConvertData(results: parsedResult, error: nil)
    }
    
    //MARK: SharedInstance
    class func sharedInstance() -> ParseClient {
        struct Singleton{
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
}