 //
 //  TrayViewController.swift
 //  FoodApp
 //
 //  Created by Victor.
 //  Copyright © 2017 Victor. All rights reserved.
 //
 
 import UIKit
 import MapKit
 import CoreLocation
 
 class TrayViewController: UIViewController {
    
    @IBOutlet weak var menuBarBtn: UIBarButtonItem!
    
    @IBOutlet weak var tbvMeals: UITableView!
    @IBOutlet weak var viewTotal: UIView!
    @IBOutlet weak var viewAddress: UIView!
    @IBOutlet weak var viewMap: UIView!
    @IBOutlet weak var lbTotal: UILabel!
    @IBOutlet weak var tbAddress: UITextField!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var bAddPayment: UIButton!
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuBarBtn.target = self.revealViewController()
            menuBarBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        if Tray.currentTray.items.count == 0 {
            
            //Showing a message here
            let lbEmptyTray = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
            lbEmptyTray.center = self.view.center
            lbEmptyTray.textAlignment = NSTextAlignment.center
            lbEmptyTray.text = "Ваша корзина пуста. Сначала выберите еду."
            
            self.view.addSubview(lbEmptyTray)
            
            
        } else {
            
            //Display all of the UI controllers
            self.tbvMeals.isHidden = false
            self.viewTotal.isHidden = false
            self.viewAddress.isHidden = false
            self.viewMap.isHidden = false
            self.bAddPayment.isHidden = false
            
            loadMeals()
        }
        
        //Show current user's location
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            
            self.map.showsUserLocation = true
        }
    }
    
    @IBAction func addPayment(_ sender: UIButton) {
        
        if tbAddress.text == "" {
            
            //Showing alert that this field is required.
            let alertController = UIAlertController(title: "No Address", message: "Address is requiref", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                self.tbAddress.becomeFirstResponder()
            })
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
            
        } else {
            Tray.currentTray.address = tbAddress.text
            self.performSegue(withIdentifier: "AddPayment", sender: self)
        }
        
    }
    
    func loadMeals() {
        self.tbvMeals.reloadData()
        self.lbTotal.text = "₽\(Tray.currentTray.getTotal())"
    }
 }
 
 
 extension TrayViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last! as CLLocation
        
        let center = CLLocationCoordinate2D (
            latitude: location.coordinate.latitude ,
            longitude: location.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.setRegion(region, animated: true)
        
    }
 }
 
 extension TrayViewController: UITableViewDelegate {}
 
 extension TrayViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Tray.currentTray.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "TrayItemCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath) as! TrayViewCell
        
        let tray = Tray.currentTray.items[indexPath.row]
        cell.lbQty.text = "\(tray.qty)"
        cell.lbMealName.text = tray.meal.name
        cell.lbSubTotal.text = "₽\(tray.meal.price! * Float(tray.qty))"
        
        return cell
    }
 }
 
 extension TrayViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let address = textField.text
        let geocoder = CLGeocoder()
        Tray.currentTray.address = address
        
        geocoder.geocodeAddressString(address!) { (placemarks, error) in
            
            if (error != nil) {
                print("Error", error ?? "")
            }
            
            if let placemark = placemarks?.first {
                
                let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
                let region = MKCoordinateRegion(
                    center: coordinates,
                    span: MKCoordinateSpanMake(0.01, 0.01)
                )
                
                self.map.setRegion(region, animated: true)
                self.locationManager.stopUpdatingLocation()
                
                let dropPin = MKPointAnnotation()
                dropPin.coordinate = coordinates
                
                self.map.addAnnotation(dropPin)
            }
        }
        return true
    }
 }
 
 
 
 
 
