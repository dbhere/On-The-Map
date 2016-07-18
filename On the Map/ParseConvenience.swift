//
//  ParseConvenience.swift
//  On the Map
//
//  Created by HhhotDog on 16/7/12.
//  Copyright © 2016年 Alexscott. All rights reserved.
//

import Foundation

extension ParseClient {
    func getStudentLocations(parameters:[String: AnyObject], completionHandlerForGetStudentLocation:(success: Bool, errorString: String?) -> Void) {
        taskForGetMethod(Methods.StudentLocation, parameters: parameters) { (results, error) in
            guard error == nil else {
                completionHandlerForGetStudentLocation(success: false, errorString: "Cannot find studentLocations Data.")
                return
            }
            guard let locationResults = results[JSONResponseKeys.Results] as? [[String: AnyObject]] else {
                completionHandlerForGetStudentLocation(success: false, errorString: "Cannot find studentLocations Data.")
                return
            }
            self.studentLocations = StudentLocation.locationsFromResults(locationResults)
            completionHandlerForGetStudentLocation(success: true, errorString: nil)
        }
    }
    
    func queryAStudentLocation(parameters: [String: AnyObject], completionHandlerForQueryLocation: (success: Bool, studentLocations:[StudentLocation]?, errorString: String?) -> Void) {
        taskForGetMethod(Methods.StudentLocation, parameters: parameters) { (results, error) in
            guard error == nil else {
                completionHandlerForQueryLocation(success: false, studentLocations: nil, errorString: "cannot find related studentLocation.")
                return
            }
            
            guard let locationResults = results[JSONResponseKeys.Results] as? [[String: AnyObject]] else {
                completionHandlerForQueryLocation(success: false, studentLocations: nil, errorString: "cannot find related studentLocation.")
                return
            }
            let studentLocations = StudentLocation.locationsFromResults(locationResults)
            completionHandlerForQueryLocation(success: true, studentLocations: studentLocations, errorString: nil)
        }
    }
    
    func postStudentLocation(studentLocation: StudentLocation, completionHandlerForPostStudentLocation: (success: Bool, errorString: String?) -> Void) {
        let jsonBodyString = jsonBodyOfLocation(studentLocation)
        taskForPostMethod(Methods.StudentLocation, parameters: [:], jsonBody: jsonBodyString) { (results, error) in
            guard error == nil else {
                completionHandlerForPostStudentLocation(success: false, errorString: "Cannot post studentLocation.")
                return
            }
            guard let _ = results[JSONResponseKeys.ObjectId] as? String else {
                completionHandlerForPostStudentLocation(success: false, errorString: "Cannot post studentLocation.")
                return
            }
            completionHandlerForPostStudentLocation(success: true, errorString: nil)
        }
    }
    
    func updateAStudentLocation(studentLocation: StudentLocation, completionHandlerForUpdateLocation: (success: Bool, errorString: String?) -> Void) {
        let newMethod = subtituteKeyInMethod(Methods.UpdateStudentLocation, key: URLKeys.ObjectId, value: studentLocation.objectId!)!
        let jsonBodyString = jsonBodyOfLocation(studentLocation)
        taskForPutMethod(newMethod, parameters: [:], jsonBody: jsonBodyString) { (results, error) in
            guard error == nil else {
                completionHandlerForUpdateLocation(success: false, errorString: "cannot update location.")
                return
            }
            guard let _ = results[JSONResponseKeys.UpdatedAt] as? String else {
                completionHandlerForUpdateLocation(success: false, errorString: "cannot update location.")
                return
            }
            completionHandlerForUpdateLocation(success: true, errorString: nil)
        }
        
    }
    
    //helpers to get jsonBodyString
    private func jsonBodyOfLocation(studentLocation: StudentLocation) -> String{
        return  "{\"\(JSONBodyKeys.UniqueKey)\": \"\(studentLocation.uniqueKey)\", \"\(JSONBodyKeys.FirstName)\": \"\(studentLocation.firstName)\", \"\(JSONBodyKeys.LastName)\": \"\(studentLocation.lastName)\", \"\(JSONBodyKeys.MapString)\": \"\(studentLocation.mapString)\", \"\(JSONBodyKeys.MediaURL)\": \"\(studentLocation.mediaURL)\", \"\(JSONBodyKeys.Latitude)\": \(studentLocation.latitude), \"\(JSONBodyKeys.Longitude)\": \(studentLocation.longitude)}"
    }
}