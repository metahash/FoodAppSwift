//
//  MealDetailsViewController.swift
//  FoodApp
//
//  Created by Victor.
//  Copyright © 2017 Victor. All rights reserved.
//

import UIKit

class MealDetailsViewController: UIViewController {
    
    @IBOutlet weak var imgMeal: UIImageView!
    @IBOutlet weak var lbMealName: UILabel!
    @IBOutlet weak var lbMealSortDesscription: UILabel!
    
    @IBOutlet weak var lbQty: UILabel!
    @IBOutlet weak var lbTotal: UILabel!
    
    var meal: Meal?
    var restaurant: Restaurant?
    var qty = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMeal()
    }
    
    func loadMeal() {
        
        if let price = meal?.price {
            lbTotal.text = "₽\(price)"
        }
        
        lbMealName.text = meal?.name
        lbMealSortDesscription.text = meal?.short_description
        if let imageUrl = meal?.image {
            Helpers.loadImage(imgMeal, "\(imageUrl)")
        }
        
    }
    @IBAction func addQty(_ sender: UIButton) {
        if qty < 99 {
            qty += 1
            lbQty.text = String(qty)
            
            if let price = meal?.price {
                lbTotal.text = "₽\(price * Float(qty))"
            }
        }
    }
    
    @IBAction func removeQty(_ sender: UIButton) {
        if qty >= 2 {
            qty -= 1
            lbQty.text = String(qty)
            
            if let price = meal?.price {
                lbTotal.text = "₽\(price * Float(qty))"
            }
        }
    }
    
    @IBAction func addToTray(_ sender: UIButton) {
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
        image.image = UIImage(named: "button_chicken")
        image.center = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height-100)
        self.view.addSubview(image)
        
        UIView.animate(withDuration: 2.0,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseOut,
                       animations: { CGPoint(x: self.view.frame.width - 40, y: 24) },
                       completion: { _ in
                        image.removeFromSuperview()
                        
                        let trayItem = TrayItem(meal: self.meal!, qty: self.qty)
                        //If those requirements are not met
                        
                        guard let trayRestaurant = Tray.currentTray.restaurant, let currentRestaurant = self.restaurant else {
                            
                            Tray.currentTray.restaurant = self.restaurant
                            Tray.currentTray.items.append(trayItem)
                            return
                        }
                        
                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                        
                        //If ordering meal from the same restaurant
                        if trayRestaurant.id == currentRestaurant.id {
                            let inTray = Tray.currentTray.items.index(where: { (item) -> Bool in
                                return item.meal.id == trayItem.meal.id!
                            })
                            
                            if let index = inTray {
                                let alertView = UIAlertController(
                                    title: "Add more?",
                                    message: "Your tray already has this meal. Do you want to add more?",
                                    preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "Add more", style: .default, handler: { (action: UIAlertAction!) in
                                    Tray.currentTray.items[index].qty += self.qty
                                })
                                alertView.addAction(okAction)
                                alertView.addAction(cancelAction)
                                self.present(alertView, animated: true, completion: nil)
                            } else {
                                Tray.currentTray.items.append(trayItem)
                            }
                            
                        }
                        else {
                            //If ordering meal from the another restaurant
                            let alertView = UIAlertController(
                                title: "Start new tray?",
                                message: "You're ordering meal from another restaurant. Would you like to clear the current tray",
                                preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "New Tray", style: .default, handler: { (action: UIAlertAction!) in
                                Tray.currentTray.items = []
                                Tray.currentTray.items.append(trayItem)
                                Tray.currentTray.restaurant = self.restaurant
                            })
                            alertView.addAction(okAction)
                            alertView.addAction(cancelAction)
                            self.present(alertView, animated: true, completion: nil)
                        }
                        
        })
        
        
    }
    
}
