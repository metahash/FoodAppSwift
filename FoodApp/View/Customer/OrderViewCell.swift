//
//  OrderViewCell.swift
//  FoodApp
//
//  Created by Victor.
//  Copyright © 2017 Victor. All rights reserved.
//

import UIKit

class OrderViewCell: UITableViewCell {
    
    @IBOutlet weak var lbQty: UILabel!
    @IBOutlet weak var lbMealName: UILabel!
    @IBOutlet weak var lbSubTotal: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lbQty.layer.borderColor = UIColor.gray.cgColor
        lbQty.layer.borderWidth = 1.0
        lbQty.layer.cornerRadius = 10
        
    }
    
}
