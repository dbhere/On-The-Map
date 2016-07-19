//
//  LoginViewController.swift
//  On the Map
//
//  Created by HhhotDog on 16/7/11.
//  Copyright © 2016年 Alexscott. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    //MARK: Properties
    var keyboardOnScreen: Bool = false
    //MARK: Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var udacityImageView: UIImageView!
    @IBOutlet weak var facebookLoginButton: UIButton!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        setUIEnabled(true)
        loginButton.layer.cornerRadius = 5
        facebookLoginButton.layer.cornerRadius = 5
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToNotification(UIKeyboardWillShowNotification, selector: #selector(keyboardWillShow))
        subscribeToNotification(UIKeyboardWillHideNotification, selector: #selector(keyboardWillHide))
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    //MARK: - Actions
    @IBAction func loginUdacity(){
        userDidTapView()
        //check whether username/password is filled
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            displayError("Empty username/password.")
            return
        }
        guard Reachability.isConnectedToNetwork() == true else {
            displayError("No Internet Connection.")
            return
        }
        
        setUIEnabled(false)
        let userInfo = [UdacityClient.JSONBodyKeys.Username: usernameTextField.text!,
                        UdacityClient.JSONBodyKeys.Password: passwordTextField.text!]
        UdacityClient.sharedInstance().creatASession(userInfo) { (success, accountKey, errorString) in
            guard success == true else {
                dispatch_sync(dispatch_get_main_queue()){
                    self.setUIEnabled(true)
                    self.displayError(errorString!)
                }
                return
            }
            UdacityClient.sharedInstance().getPublicUserData(accountKey) { (success, udacityUser, error) in
                guard success == true else {
                    self.displayError(error!.localizedDescription)
                    return
                }
                UdacityClient.sharedInstance().clientUser = udacityUser
                UdacityClient.sharedInstance().isFacebook = false
            }
            
            let pinsTabBarVC = self.storyboard?.instantiateViewControllerWithIdentifier("PinsTabBarViewController") as! UITabBarController
            dispatch_async(dispatch_get_main_queue()){
                self.setUIEnabled(true)
                self.presentViewController(pinsTabBarVC, animated: true, completion: nil)
            }
        }
    }
    
    //login with facebook
    @IBAction func loginWithFacebook(){
        let fbLoginManager = FBSDKLoginManager()
        setUIEnabled(false)
        fbLoginManager.logInWithReadPermissions(["public_profile"], fromViewController: nil) { (result, error) in
            guard error == nil  && result.token != nil else{
                self.setUIEnabled(true)
                return
            }
            UdacityClient.sharedInstance().loginWithFacebook(result.token.tokenString, completionHandlerForLoginWithFacebook: { (success, accountKey, errorString) in
                guard success == true else {
                    dispatch_sync(dispatch_get_main_queue()){
                        self.setUIEnabled(true)
                        self.displayError(errorString!)
                    }
                    return
                }
                UdacityClient.sharedInstance().getPublicUserData(accountKey) { (success, udacityUser, error) in
                    guard success == true else {
                        self.displayError(error!.localizedDescription)
                        return
                    }
                    UdacityClient.sharedInstance().clientUser = udacityUser
                    UdacityClient.sharedInstance().isFacebook = true
                }
                
                let pinsTabBarVC = self.storyboard?.instantiateViewControllerWithIdentifier("PinsTabBarViewController") as! UITabBarController
                dispatch_async(dispatch_get_main_queue()){
                    self.setUIEnabled(true)
                    self.presentViewController(pinsTabBarVC, animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func signUpUdacity(){
        let signUpUrl = NSURL(string: "https://cn.udacity.com/signup")!
        UIApplication.sharedApplication().openURL(signUpUrl)
    }
    @IBAction func userDidTapView(){
        resignIfFirstResponder(usernameTextField)
        resignIfFirstResponder(passwordTextField)
    }
    
    //MARK: UIHelpers
    private func displayError(error: String){
        let alertVC = UIAlertController(title: nil, message: error, preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
        alertVC.addAction(dismissAction)
        self.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    private func setUIEnabled(enabled: Bool){
        usernameTextField.enabled = enabled
        passwordTextField.enabled = enabled
        loginButton.enabled = enabled
        facebookLoginButton.enabled = enabled
        if enabled{
            loginButton.alpha = 1.0
            activityIndicator.stopAnimating()
            passwordTextField.text = ""
        }else {
            loginButton.alpha = 0.5
            activityIndicator.startAnimating()
        }
    }
    
    private func resignIfFirstResponder(textField: UITextField){
        if textField.isFirstResponder(){
            textField.resignFirstResponder()
        }
    }
    
    //MARK: keyboard hide and show related functions
    func keyboardWillShow(notification:NSNotification){
        udacityImageView.hidden = true
    }
    func keyboardWillHide(notification:NSNotification){
        udacityImageView.hidden = false
    }
    
    private func subscribeToNotification(notification:String, selector:Selector){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: notification, object: nil)
    }
    private func unsubscribeFromAllNotifications(){
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension LoginViewController: UITextFieldDelegate{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
