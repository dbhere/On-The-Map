//
//  LoginViewController.swift
//  On the Map
//
//  Created by HhhotDog on 16/7/11.
//  Copyright © 2016年 Alexscott. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    //MARK: Actions
    @IBAction func loginUdacity(){
        //check whether username/password is filled
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            displayError("Empty username/password.")
            return
        }
        let userInfo = [UdacityClient.JSONBodyKeys.Username: usernameTextField.text!,
                        UdacityClient.JSONBodyKeys.Password: passwordTextField.text!]
        UdacityClient.sharedInstance().creatASession(userInfo) { (success, accountKey, errorString) in
            guard success == true else {
                self.displayError(errorString!)
                return
            }
            let pinsMapVC = self.storyboard?.instantiateViewControllerWithIdentifier("PinsMapViewController") as! PinsMapViewController
            pinsMapVC.accountKey = accountKey
            dispatch_async(dispatch_get_main_queue()){
                self.presentViewController(pinsMapVC, animated: true, completion: nil)
            }
        }
    }
    @IBAction func signUpUdacity(){
        let signUpUrl = NSURL(string: "https://cn.udacity.com/signup")!
        UIApplication.sharedApplication().openURL(signUpUrl)
    }
    
    private func displayError(error: String){
        let alertVC = UIAlertController(title: nil, message: error, preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .Default) { (action) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alertVC.addAction(dismissAction)
        self.presentViewController(alertVC, animated: true, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
