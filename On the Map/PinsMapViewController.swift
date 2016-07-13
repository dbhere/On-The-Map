//
//  PinsMapViewController.swift
//  On the Map
//
//  Created by HhhotDog on 16/7/11.
//  Copyright © 2016年 Alexscott. All rights reserved.
//

import UIKit
import MapKit

class PinsMapViewController: UIViewController, MKMapViewDelegate {
    //MARK: Properties
    var parseClientSharedInstance: ParseClient!
    var udacityClientSahredInstance: UdacityClient!
    
    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        parseClientSharedInstance = ParseClient.sharedInstance()
        udacityClientSahredInstance = UdacityClient.sharedInstance()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(logout))
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(reloadUserLocation)),
            UIBarButtonItem(image: UIImage(named: "pin"), style: .Plain, target: self, action: #selector(addUserPin))]
        reloadUserLocation()
    }
    
    //MARK: UIRelated
    func setUIEnabled(enabled: Bool){
        for item in self.navigationItem.rightBarButtonItems! {
           item.enabled = enabled
        }
        self.navigationItem.leftBarButtonItem?.enabled = enabled
        if enabled {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
    }
    
    func displayError(errorString: String){
        let alertVC = UIAlertController(title: nil, message: errorString, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
        alertVC.addAction(alertAction)
        self.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    // MARK: Udacity
    func logout(){
        UdacityClient.sharedInstance().logOutOfASession { (success, errorString) in
            guard success == true else {
                dispatch_async(dispatch_get_main_queue()){
                    self.displayError(errorString!)
                }
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        }
    }
    
    // MARK: - UserLocation
    func getAnotationsFromStudentLocations(studentLocations: [StudentLocation]) -> [MKPointAnnotation] {
        var annotations = [MKPointAnnotation]()
        for studentLocation in studentLocations {
            let lat = CLLocationDegrees(studentLocation.latitude)
            let long = CLLocationDegrees(studentLocation.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(studentLocation.firstName) \(studentLocation.lastName)"
            annotation.subtitle = studentLocation.mediaURL
            annotations.append(annotation)
        }
        return annotations
    }
    
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
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotations(self.getAnotationsFromStudentLocations(self.parseClientSharedInstance.studentLocations))
                self.setUIEnabled(true)
            }
        }
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
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = MKPinAnnotationView.purplePinColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let subtitle = view.annotation?.subtitle, urlString = subtitle, url = NSURL(string: urlString) where app.canOpenURL(url){
                app.openURL(url)
            } else {
                displayError("Invalid URL.")
            }
        }
    }
}
