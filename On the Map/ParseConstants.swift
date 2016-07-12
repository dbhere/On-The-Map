//
//  ParseConstants.swift
//  On the Map
//
//  Created by HhhotDog on 16/7/12.
//  Copyright © 2016年 Alexscott. All rights reserved.
//

extension ParseClient{
    struct Constants {
        static let ParseApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RestApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        static let ApiScheme = "https"
        static let ApiHost = "api.parse.com"
        static let ApiPath = "/1/classes"
    }
    
    struct URLKeys {
        static let ObjectId = "objectId"
    }
    
    struct Methods {
        static let StudentLocation = "/StudentLocation"
        static let UpdateStudentLocation = "StudentLocaion/<objectId>"
    }
    
    struct JSONResponseKeys {
        static let Results = "results"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let ObjectId = "objectId"
        static let UniqueKey = "uniqueKey"
    }
}
