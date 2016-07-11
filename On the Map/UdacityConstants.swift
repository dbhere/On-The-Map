//
//  UdacityConstants.swift
//  On the Map
//
//  Created by HhhotDog on 16/7/10.
//  Copyright © 2016年 Alexscott. All rights reserved.
//

extension UdacityClient{
    struct Constants {
        static let ApiScheme: String = "https"
        static let ApiHost: String = "www.udacity.com"
        static let ApiPath: String = "/api"
    }
    
    struct Methods {
        static let Session = "/session"
        static let GetUserData = "/users/<user_id>"
    }
    
    struct URLKeys {
        static let UserId = "user_id"
    }
    
    struct JSONBodyKeys {
        static let Username = "username"
        static let Password = "password"
    }
    
    struct JSONResponseKeys {
        static let Account: String = "account"
        static let User: String = "user"
        static let AccountKey: String = "key"
        static let LastName: String = "last_name"
        static let FirstName: String = "first_name"
        static let Session: String = "session"
        static let Id: String = "id"
    }

}
