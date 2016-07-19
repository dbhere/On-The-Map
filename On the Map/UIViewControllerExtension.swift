//
//  UIViewControllerExtension.swift
//  On the Map
//
//  Created by HhhotDog on 16/7/19.
//  Copyright © 2016年 Alexscott. All rights reserved.
//

extension UIViewController{
    
    // Alert user with AlertController
    func displayError(error: String){
        let alertVC = UIAlertController(title: nil, message: error, preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
        alertVC.addAction(dismissAction)
        presentViewController(alertVC, animated: true, completion: nil)
    }
    
    // MARK: Logout
    func logout(){
        if UdacityClient.sharedInstance().isFacebook{
            let fbManager = FBSDKLoginManager()
            fbManager.logOut()
        }else{
            UdacityClient.sharedInstance().logOutOfASession { (success, errorString) in
                guard success == true else {
                    dispatch_async(dispatch_get_main_queue()){
                        print(errorString!)
                    }
                    return
                }
            }
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - Add New Pin
    func addUserPin(){
        //check if the user has a pin
        let parameters = [ParseClient.ParameterKeys.Where: "{\"\(ParseClient.ParameterKeys.UniqueKey)\": \"\(UdacityClient.sharedInstance().clientUser!.accountKey)\"}"]
        
        ParseClient.sharedInstance().queryAStudentLocation(parameters) { (success, studentLocations, errorString) in
            guard success == true else {
                dispatch_async(dispatch_get_main_queue(), {
                    print(errorString)
                    self.displayError("Bad network connection.")
                })
                return
            }
            
            if let studentLocations = studentLocations where studentLocations.count > 0 {
                //user has a pin already
                dispatch_async(dispatch_get_main_queue(), {
                    self.alertUserIfHasAPin(studentLocations[0])
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.moveToFindLoactionView(nil)
                })
            }
        }
    }
    
    //present modally to findLocationView
    func moveToFindLoactionView(objectId: String?) {
        let findLocationVC = self.storyboard?.instantiateViewControllerWithIdentifier("FindLocationViewController") as! FindLocationViewController
        findLocationVC.objectId = objectId
        presentViewController(findLocationVC, animated: true, completion: nil)
    }
    
    func alertUserIfHasAPin(studentLocation: StudentLocation){
        let message = "User \"\(UdacityClient.sharedInstance().clientUser!.firstName) \(UdacityClient.sharedInstance().clientUser!.lastName)\" Has Already Posted a Student Location. Would You Like to Overwrite The Location?"
        let alertVC = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        let overwriteAction = UIAlertAction(title: "Override", style: .Default, handler: { (action) in
            //next VC
            let objectId = studentLocation.objectId
            self.moveToFindLoactionView(objectId)
        })
        let cancleAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alertVC.addAction(cancleAction)
        alertVC.addAction(overwriteAction)
        presentViewController(alertVC, animated: true, completion: nil)
    }
}