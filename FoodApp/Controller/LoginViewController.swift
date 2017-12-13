//
//  LoginViewController.swift
//  FoodApp
//
//  Created by Victor.
//  Copyright © 2017 Victor. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {
    @IBOutlet weak var bLogin: UIButton!
    @IBOutlet weak var bLogout: UIButton!
    @IBOutlet weak var switchUser: CustomSegmentedControl!
    
    var fbLoginSuccess = false
    var userType: String = USERTYPE_CUSTOMER
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (FBSDKAccessToken.current() != nil) {
            
            bLogout.isHidden = false
            FBManager.getFBUserData(complitionHandler: {
                self.bLogin.setTitle("Продолжить как \(User.currentUser.email!)", for: .normal)
            })
        } else {
            self.bLogout.isHidden = true
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        userType = userType.capitalized
        
        if (FBSDKAccessToken.current() != nil && fbLoginSuccess == true) {
            performSegue(withIdentifier: "\(userType)View", sender: nil)
        }
        
    }
    
    @IBAction func facebookLogout(_ sender: UIButton) {
        APIManager.shared.logout { (error) in
            if error == nil {
                FBManager.shared.logOut()
                User.currentUser.resetInfo()
                self.bLogout.isHidden = true
                self.bLogin.setTitle("Войти с помощью Facebook", for: .normal)
            }
        }
    }
    
    @IBAction func facebookLogin(_ sender: UIButton) {
        
        
        if (FBSDKAccessToken.current() != nil) {
            
            performSegue(withIdentifier: "\(userType)View", sender: nil)
            
            APIManager.shared.login(userType: userType, completionHandler: { (error) in
                if error == nil {
                    self.fbLoginSuccess = true
                    self.viewWillAppear(true)
                }
            })
            
        } else {
            FBManager.shared.logIn(withReadPermissions: ["public_profile", "email"],
                                   from: self,
                                   handler: { (result, error) in
                                    
                                    if (error == nil) {
                                        FBManager.getFBUserData(complitionHandler: {
                                            APIManager.shared.login(userType: self.userType, completionHandler: { (error) in
                                                if error == nil {
                                                    self.fbLoginSuccess = true
                                                    self.viewWillAppear(true)
                                                }
                                            })
                                        })
                                    }
            })
        }
    }
    
    @IBAction func switchAccount(_ sender: CustomSegmentedControl) {
        let type = switchUser.selectedSegmentIndex
        
        if type == 0 {
            userType = USERTYPE_CUSTOMER
            userType = userType.capitalized
            print("select customer==\(userType)+View")
            
        }
        else {
            userType = USERTYPE_DRIVER
            userType = userType.capitalized
            print("select driver==\(userType)+View")
        }
    }
}
