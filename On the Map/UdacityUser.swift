//
//  UdacityUser.swift
//  On the Map
//
//  Created by HhhotDog on 16/7/10.
//  Copyright © 2016年 Alexscott. All rights reserved.
//

struct UdacityUser {
    let accountKey: String
    let firstName: String
    let lastName: String
    
    init(dictionary: [String: AnyObject]){
        accountKey = dictionary[UdacityClient.JSONResponseKeys.AccountKey] as! String
        firstName = dictionary[UdacityClient.JSONResponseKeys.FirstName] as! String
        lastName = dictionary[UdacityClient.JSONResponseKeys.LastName] as! String
        
    }
}
