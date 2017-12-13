//
//  DriverMenuViewController.swift
//  FoodApp
//
//  Created by Victor.
//  Copyright © 2017 Victor. All rights reserved.
//

import UIKit

class DriverMenuViewController: UITableViewController {
    
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.1411764706, green: 0.1294117647, blue: 0.2431372549, alpha: 1)
        lbName.text  = User.currentUser.name
        imgAvatar.image = UIImage(named:"ava")
        if User.currentUser.pictureURL != nil {
            imgAvatar.image = try! UIImage(data: Data(contentsOf: URL(string: User.currentUser.pictureURL!)!))
        }
        imgAvatar.layer.cornerRadius = 70 / 2
        imgAvatar.clipsToBounds = true
    }
}
