//
//  PinsTableViewController.swift
//  On the Map
//
//  Created by HhhotDog on 16/7/12.
//  Copyright © 2016年 Alexscott. All rights reserved.
//

import UIKit

class PinsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //MARK: Properties
    var parseClientSharedInstance: ParseClient!
    var udacityClientSahredInstance: UdacityClient!
    var studentLocations = [StudentLocation]()
    
    //MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        parseClientSharedInstance = ParseClient.sharedInstance()
        udacityClientSahredInstance = UdacityClient.sharedInstance()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(logout))
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(reloadUserLocation)),
            UIBarButtonItem(image: UIImage(named: "pin"), style: .Plain, target: self, action: #selector(addUserPin))]
        reloadUserLocation()
    }

    //MARK: UIRelated
    func setUIEnabled(enabled: Bool){
        for item in self.navigationItem.rightBarButtonItems! {
            item.enabled = enabled
        }
        self.navigationItem.leftBarButtonItem?.enabled = enabled
        if enabled{
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
    }
    
    func displayError(errorString: String) {
        let alertVC = UIAlertController(title: nil, message: errorString, preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
        alertVC.addAction(dismissAction)
        self.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    //MARK: Action
    @IBAction func backPinsView(segue: UIStoryboardSegue){
        self.reloadUserLocation()
    }
    
    // MARK: Udacity
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
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - Add New Pin
    func addUserPin(){
        //check if the user has a pin
        let parameters = [ParseClient.ParameterKeys.Where: "{\"\(ParseClient.ParameterKeys.UniqueKey)\": \"\(udacityClientSahredInstance.clientUser!.accountKey)\"}"]
        
        parseClientSharedInstance.queryAStudentLocation(parameters) { (success, studentLocations, errorString) in
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
    private func moveToFindLoactionView(objectId: String?) {
        let findLocationVC = self.storyboard?.instantiateViewControllerWithIdentifier("FindLocationViewController") as! FindLocationViewController
        findLocationVC.objectId = objectId
        self.presentViewController(findLocationVC, animated: true, completion: nil)
    }
    
    private func alertUserIfHasAPin(studentLocation: StudentLocation){
        let message = "User \"\(self.udacityClientSahredInstance.clientUser!.firstName) \(self.udacityClientSahredInstance.clientUser!.lastName)\" Has Already Posted a Student Location. Would You Like to Overwrite Their Location?"
        let alertVC = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        let overwriteAction = UIAlertAction(title: "Override", style: .Default, handler: { (action) in
            //next VC
            let objectId = studentLocation.objectId
            self.moveToFindLoactionView(objectId)
        })
        let cancleAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alertVC.addAction(cancleAction)
        alertVC.addAction(overwriteAction)
        self.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    // MARK: - UserLocation
    func reloadUserLocation() {
        setUIEnabled(false)
        let parameters = [ParseClient.ParameterKeys.Limit: 100,
                          ParseClient.ParameterKeys.order: "-updatedAt"]
        parseClientSharedInstance.getStudentLocations(parameters) { (success, errorString) in
            if !success {
                dispatch_async(dispatch_get_main_queue(), { 
                    self.displayError(errorString!)
                    self.setUIEnabled(true)
                })
                return
            }
            self.studentLocations = self.parseClientSharedInstance.studentLocations
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
                self.setUIEnabled(true)
            }
        }
    }
    
    //MARK: - TableViewDelegate and TableViewDataSource
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let studentLocation = studentLocations[indexPath.row]
        if let url = NSURL(string: studentLocation.mediaURL) where UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
        } else {
            displayError("Invalid URL.")
        }
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentLocations.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("pinTableViewCell")!
        let studentLocation = studentLocations[indexPath.row]
        cell.textLabel?.text = "\(studentLocation.firstName) \(studentLocation.lastName)"
        cell.detailTextLabel?.text = studentLocation.mediaURL
        cell.imageView?.image = UIImage(named: "pin")
        return cell
    }
}
