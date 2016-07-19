//
//  ShareLinkWithLocationViewController.swift
//  On the Map
//
//  Created by HhhotDog on 16/7/15.
//  Copyright © 2016年 Alexscott. All rights reserved.
//

import UIKit
import MapKit

class ShareLinkWithLocationViewController: UIViewController {
    //MARK: Property
    var userLocationDict = [String: AnyObject]()
    var objectId: String?
    var userCoordinate: CLLocationCoordinate2D?
    let textPlaceHolder = "Enter a Link to Share Here"
    
    //MARK: Outlet
    @IBOutlet weak var urlTextView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.layer.cornerRadius = 5
        urlTextView.delegate = self
        setUIEnabled(true)
        setMapWithPin()
    }

    //MARK: - Action
    @IBAction func cancel(){
        self.performSegueWithIdentifier("backPinsView", sender: nil)
    }
    
    @IBAction func submitLocation(){
        guard checkUrlValid(urlTextView.text) == true else {
            displayError("Enter a Valid Link.")
            urlTextView.text = self.textPlaceHolder
            return
        }
        setUIEnabled(false)
        
        let udacityUser = UdacityClient.sharedInstance().clientUser!
        userLocationDict[StudentLocation.Constants.MediaURL] = urlTextView.text
        userLocationDict[StudentLocation.Constants.FirstName] = udacityUser.firstName
        userLocationDict[StudentLocation.Constants.LastName] = udacityUser.lastName
        userLocationDict[StudentLocation.Constants.UniqueKey] = udacityUser.accountKey
        userLocationDict[StudentLocation.Constants.ObjectId] = objectId
        let studentLocation = StudentLocation(dictionary: userLocationDict)
        
        if objectId != nil {
            //user already had a pin
            ParseClient.sharedInstance().updateAStudentLocation(studentLocation, completionHandlerForUpdateLocation: { (success, errorString) in
                guard success == true else {
                    dispatch_async(dispatch_get_main_queue(), {
                        print(errorString!)
                        self.displayError("Submit Faild. Try again later.")
                        self.setUIEnabled(true)
                    })
                    return
                }
                dispatch_async(dispatch_get_main_queue(), { 
                    self.performSegueWithIdentifier("backPinsView", sender: nil)
                })
            })            
        } else {
            //user doesn't have a pin
            ParseClient.sharedInstance().postStudentLocation(studentLocation, completionHandlerForPostStudentLocation: { (success, errorString) in
                guard success == true else {
                    dispatch_async(dispatch_get_main_queue(), {
                        print(errorString!)
                        self.displayError("Submit Faild. Try again later.")
                        self.setUIEnabled(true)
                    })
                    return
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.performSegueWithIdentifier("backPinsView", sender: nil)
                })
            })
        }
    }
    
    //MARK: - UIHelpers
    private func checkUrlValid(urlString: String) -> Bool{
        if urlString == "" || urlString == self.textPlaceHolder {
            return false
        }
        guard let url = NSURL(string: urlString) where UIApplication.sharedApplication().canOpenURL(url) else {
            return false
        }
        return true
    }
    
    private func setUIEnabled(enabled: Bool){
        submitButton.enabled = enabled
        if enabled{
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
    }
    
    //configure the map
    private func setMapWithPin(){
        mapView.zoomEnabled = false
        mapView.scrollEnabled = false
        mapView.region = MKCoordinateRegion(center: userCoordinate!, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        let annotation = MKPointAnnotation()
        guard let userCoordinate = userCoordinate else {
            displayError("Cannot find userLocation On the map.")
            return
        }
        annotation.coordinate = userCoordinate
        mapView.addAnnotation(annotation)
    }
}

//MARK: - UITextViewDelegate
extension ShareLinkWithLocationViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if textView.text == self.textPlaceHolder{
            textView.text = "https://"
        }
        return true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            if textView.text == "" || textView.text == "https://" {
                textView.text = self.textPlaceHolder
            }
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
