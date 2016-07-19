//
//  UIViewControllerExtension.swift
//  On the Map
//
//  Created by HhhotDog on 16/7/19.
//  Copyright © 2016年 Alexscott. All rights reserved.
//

extension UIViewController{
    func displayError(error: String){
        let alertVC = UIAlertController(title: nil, message: error, preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
        alertVC.addAction(dismissAction)
        presentViewController(alertVC, animated: true, completion: nil)
    }
}