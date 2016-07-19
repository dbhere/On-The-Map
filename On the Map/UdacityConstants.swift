//
//  UdacityConstants.swift
//  On the Map
//
//  Created by HhhotDog on 16/7/10.
//  Copyright © 2016年 Alexscott. All rights reserved.
//

extension UdacityClient{
    struct Constants {
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
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
        static let Account = "account"
        static let User = "user"
        static let AccountKey = "key"
        static let LastName = "last_name"
        static let FirstName = "first_name"
        static let Session = "session"
        static let Id = "id"
    }
    
    struct Facebook {
        static let FacebookMobile = "facebook_mobile"
        static let AccessToken = "access_token"
    }

}
