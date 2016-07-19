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
    
    //MARK: Unwind segue
    @IBAction func backPinsView(segue: UIStoryboardSegue){
        self.reloadUserLocation()
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
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
                self.setUIEnabled(true)
            }
        }
    }
    
    //MARK: - TableViewDelegate and TableViewDataSource
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let studentLocation = parseClientSharedInstance.studentLocations[indexPath.row]
        if let url = NSURL(string: studentLocation.mediaURL) where UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
        } else {
            displayError("Invalid URL.")
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parseClientSharedInstance.studentLocations.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("pinTableViewCell")!
        let studentLocation = parseClientSharedInstance.studentLocations[indexPath.row]
        cell.textLabel?.text = "\(studentLocation.firstName) \(studentLocation.lastName)"
        cell.detailTextLabel?.text = studentLocation.mediaURL
        cell.imageView?.image = UIImage(named: "pin")
        return cell
    }
    
}
