//
//  FindLocationViewController.swift
//  On the Map
//
//  Created by HhhotDog on 16/7/13.
//  Copyright © 2016年 Alexscott. All rights reserved.
//

import UIKit
import MapKit

class FindLocationViewController: UIViewController {
    //MARK: Properties
    var objectId: String? = nil
    let textPlaceHolder = "Enter Your Location Here"
    
    //MARK: Outlets
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextView.delegate = self
        findButton.layer.cornerRadius = 5
        setUIEnabled(true)
    }
    
    //MARK: - Action
    @IBAction func findOnTheMap() {
        if locationTextView.text == self.textPlaceHolder || locationTextView.text.isEmpty {
            displayError("Must Enter a location.")
            return
        }
        setUIEnabled(false)
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = locationTextView.text
        
        let localSearchTask = MKLocalSearch(request: request)
        localSearchTask.startWithCompletionHandler { (response, error) in
            func sendError() {
                dispatch_async(dispatch_get_main_queue(), {
                    self.displayError("Could Not Geocode the String.")
                    self.locationTextView.text = self.textPlaceHolder
                    self.setUIEnabled(true)
                })
            }
            guard error == nil else {
                sendError()
                return
            }
            
            guard let response = response where response.mapItems.count > 0 else {
                sendError()
                return
            }
            
            //pick the first mapItem
            let mapItem = response.mapItems[0]
            let coordinate = mapItem.placemark.coordinate
            let userLocationDict:[String: AnyObject] = [StudentLocation.Constants.MapString: self.locationTextView.text,
                StudentLocation.Constants.Latitude: Double(coordinate.latitude),
                StudentLocation.Constants.Longitude: Double(coordinate.longitude)]
            
            dispatch_async(dispatch_get_main_queue(), { 
                let shareLinkVC = self.storyboard?.instantiateViewControllerWithIdentifier("ShareLinkWithLocation") as! ShareLinkWithLocationViewController
                shareLinkVC.userLocationDict = userLocationDict
                shareLinkVC.objectId = self.objectId
                shareLinkVC.userCoordinate = coordinate
                self.presentViewController(shareLinkVC, animated: true, completion: nil)
            })
        }
    }
    
    @IBAction func cancel() {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    //MARK: - UIHelpers
    
    private func setUIEnabled(enabled: Bool){
        findButton.enabled = enabled
        if enabled{
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
    }
}

//MARK: - UITextViewDelegate
extension FindLocationViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if textView.text == self.textPlaceHolder{
            textView.text = ""
        }
        return true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            if textView.text == "" {
                textView.text = self.textPlaceHolder
            }
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}