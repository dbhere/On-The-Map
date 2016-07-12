//
//  StudentLocation.swift
//  On the Map
//
//  Created by HhhotDog on 16/7/12.
//  Copyright © 2016年 Alexscott. All rights reserved.
//

struct StudentLocation {
    let objectId: String
    let uniqueKey: String
    let firstName: String
    let lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Double
    var longitude: Double
    
    init(dictionary: [String: AnyObject]){
        self.objectId = dictionary[ParseClient.JSONResponseKeys.ObjectId] as! String
        self.uniqueKey = dictionary[ParseClient.JSONResponseKeys.UniqueKey] as! String
        self.firstName = dictionary[ParseClient.JSONResponseKeys.FirstName] as! String
        self.lastName = dictionary[ParseClient.JSONResponseKeys.LastName] as! String
        self.mapString = dictionary[ParseClient.JSONResponseKeys.MapString] as! String
        self.mediaURL = dictionary[ParseClient.JSONResponseKeys.MediaURL] as! String
        self.latitude = dictionary[ParseClient.JSONResponseKeys.Latitude] as! Double
        self.longitude = dictionary[ParseClient.JSONResponseKeys.Longitude] as! Double
    }
    
    static func locationsFromResults(results:[[String: AnyObject]]) -> [StudentLocation]{
        var studentLocations = [StudentLocation]()
        for result in results{
            studentLocations.append(StudentLocation(dictionary: result))
        }
        return studentLocations
    }
}
