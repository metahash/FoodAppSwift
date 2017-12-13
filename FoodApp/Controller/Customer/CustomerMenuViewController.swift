//
//  CustomerMenuViewController.swift
//  FoodApp
//
//  Created by Victor.
//  Copyright © 2017 Victor. All rights reserved.

import UIKit

class CustomerMenuViewController: UITableViewController {
    
    @IBOutlet weak var imageAvatar: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = #colorLiteral(red: 0.1411764706, green: 0.1294117647, blue: 0.2431372549, alpha: 1)
        labelName.text  = User.currentUser.name
        imageAvatar.image = UIImage(named:"ava")
        if User.currentUser.pictureURL != nil {
            imageAvatar.image = try! UIImage(data: Data(contentsOf: URL(string: User.currentUser.pictureURL!)!))
        }
        imageAvatar.layer.cornerRadius = 70 / 2
        imageAvatar.clipsToBounds = true
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "CustomerLogout" {
            APIManager.shared.logout(completionHandler: { (error) in
                FBManager.shared.logOut()
                User.currentUser.resetInfo()
                
                //Re-render the LoginView once you completed loggin out process
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let appController = storyboard.instantiateViewController(withIdentifier: "MainController") as! LoginViewController
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window!.rootViewController = appController
            })
            
            return false
        }
        return true
    }
}
