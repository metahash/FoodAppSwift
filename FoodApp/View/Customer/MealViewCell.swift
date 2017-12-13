//
//  MealViewCell.swift
//  FoodApp
//
//  Created by Victor.
//  Copyright © 2017 Victor. All rights reserved.
//

import UIKit

class MealViewCell: UITableViewCell {
    @IBOutlet weak var lbMealName: UILabel!
    @IBOutlet weak var lbMealShortDescription: UILabel!
    @IBOutlet weak var lbMealPrice: UILabel!
    @IBOutlet weak var imgMeal: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
