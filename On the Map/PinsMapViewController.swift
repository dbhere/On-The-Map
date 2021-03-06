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
    
    //MARK: - UIRelated
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
    
    //MARK: Unwind segue
    @IBAction func backPinsView(segue: UIStoryboardSegue){
        reloadUserLocation()
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