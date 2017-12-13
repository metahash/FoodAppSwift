//
//  MealListTableViewController.swift
//  FoodApp
//
//  Created by Victor.
//  Copyright © 2017 Victor. All rights reserved.
//

import UIKit

class MealListTableViewController: UITableViewController {
    
    var restaurant: Restaurant?
    var meals = [Meal]()
    let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let restarantName = restaurant?.name {
            self.navigationItem.title = restarantName
        }
        loadMeals()
    }
    
    func loadMeals() {
        
        Helpers.showActivityIndicator(activityIndicator, view)
        
        if let restaurantId = restaurant?.id {
            APIManager.shared.getMeals(restaurantId: restaurantId, completionHandler: { (json) in
                if json != nil {
                    self.meals = []
                    
                    if let tempMeals = json["meals"].array {
                        for item in tempMeals {
                            let meal = Meal(json: item)
                            self.meals.append(meal)
                        }
                        self.tableView.reloadData()
                        Helpers.hideActivityIndicator(self.activityIndicator)
                    }
                }
                
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MealDetails" {
            let controller = segue.destination as! MealDetailsViewController
            controller.meal = meals[(tableView.indexPathForSelectedRow?.row)!]
            controller.restaurant = restaurant
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count;
    }
    
    override func tableView (_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "MealCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath) as! MealViewCell
        let meal = meals[indexPath.row]
        cell.lbMealName.text = meal.name
        cell.lbMealShortDescription.text = meal.short_description
        
        if let price = meal.price {
            cell.lbMealPrice.text = "₽\(price)"
        }
        
        if let image = meal.image {
            Helpers.loadImage(cell.imgMeal, "\(image)")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}


