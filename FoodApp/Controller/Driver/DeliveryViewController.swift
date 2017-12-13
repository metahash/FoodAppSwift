//
//  DeliveryViewController.swift
//  FoodApp
//
//  Created by Victor.
//  Copyright © 2017 Victor. All rights reserved.
//

import UIKit
import MapKit

class DeliveryViewController: UIViewController {
    
    @IBOutlet weak var menuBarBtn: UIBarButtonItem!
    
    @IBOutlet weak var lbCustomerName: UILabel!
    @IBOutlet weak var lbCustomerAddress: UILabel!
    @IBOutlet weak var imgCustomerAvatar: UIImageView!
    
    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var bComplete: UIButton!
    
    var orderId: Int?
    
    var destination: MKPlacemark?
    var source: MKPlacemark?
    
    var locationManager: CLLocationManager!
    var driverPin: MKPointAnnotation!
    var lastLocation: CLLocationCoordinate2D!
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuBarBtn.target = self.revealViewController()
            menuBarBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        //Show current Driver's location
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            
            self.map.showsUserLocation = false
        }
        
        //Running the updating location process
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(updateLocation(_:)),
            userInfo: nil,
            repeats: true)
        
    }
    
    
    @objc func updateLocation(_ sender: AnyObject) {
        APIManager.shared.updateLocation(location: self.lastLocation) { (json) in
            
            
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        loadData()
    }
    
    func loadData() {
        APIManager.shared.getCurrentDriverOrder { (json) in
            
            print(json)
            let order = json["order"]
            if let id = order["id"].int, order["status"] == "On the way" {
                
                self.orderId = id
                let from = order["address"].string!
                let to = order["restaurant"]["address"].string!
                
                let customerName = order["customer"]["name"].string!
                let customerAvatar  = order["address"].string!
                
                self.lbCustomerName.text = customerName
                self.lbCustomerAddress.text = from
                
                self.imgCustomerAvatar.image = try! UIImage(data: Data(contentsOf: URL(string:customerAvatar)!))
                self.imgCustomerAvatar.layer.cornerRadius = 50 / 2
                self.imgCustomerAvatar.clipsToBounds = true
                
                self.getLocation(from, "Customer", { (sou) in
                    
                    self.source = sou
                    self.getLocation(to, "Restaurant", { (des) in
                        self.destination = des
                        self.getDirections()   ////////AYA DADADA
                    })
                })
                
            } else {
                
                self.map.isHidden = true
                self.viewInfo.isHidden = true
                self.bComplete.isHidden = true
                
                //Showing a message here
                let lbMessage = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
                lbMessage.center = self.view.center
                lbMessage.textAlignment = NSTextAlignment.center
                lbMessage.text = "У вас нет заказов на доставку."
                
                self.view.addSubview(lbMessage)
                
            }
        }
    }
    
    @IBAction func completeOrder(_ sender: UIButton) {
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
            APIManager.shared.completeOrder(orderId: self.orderId!, completionHandler: { (json) in
                
                if json != nil {
                    //Stop updating drivers location
                    self.timer.invalidate()
                    self.locationManager.stopUpdatingLocation()
                    
                    //Redirect driver to the Ready Orders View
                    self.performSegue(withIdentifier: "ViewsOrders", sender: self)
                }
            })
        }
        let alertView = UIAlertController(title: "Заказ выполнен", message: "Вы уверены?", preferredStyle: .alert)
        alertView.addAction(cancelAction)
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
    }
}

extension DeliveryViewController: MKMapViewDelegate {
    
    // #1 - Delegate method of MKMapViewDelegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
    // #2 - Convert an address string to a location on the map
    func getLocation(_ address: String, _ title: String, _ completionHandler: @escaping(MKPlacemark) -> Void) {
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            
            if (error != nil) {
                print("Error", error ?? "")
            }
            
            if let placemark = placemarks?.first {
                let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate//
                let dropPin = MKPointAnnotation()
                dropPin.coordinate = coordinates
                dropPin.title = title
                
                self.map.addAnnotation(dropPin)
                completionHandler(MKPlacemark.init(placemark: placemark))
            }
        }
    }
    
    // #3 - Get direction and zoom to address
    func getDirections() {
        let request = MKDirectionsRequest()
        request.source = MKMapItem.init(placemark: source!)
        request.destination = MKMapItem.init(placemark: destination!)
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            
            if error != nil {
                print("Error: ", error)
            } else {
                //Show route
                self.showRoute(response: response!)
            }
        }
    }
    
    
    // #4 - Show route between locations and make a visible zoom
    func showRoute(response: MKDirectionsResponse) {
        
        for route in response.routes {
            self.map.add(route.polyline, level: MKOverlayLevel.aboveRoads)
        }
        
        var zoomRect = MKMapRectNull
        for annotation in self.map.annotations {
            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
            let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
            zoomRect = MKMapRectUnion(zoomRect, pointRect)
        }
        
        let insetWidth = -zoomRect.size.width * 0.2
        let insetHeight = -zoomRect.size.height * 0.2
        let insetRect = MKMapRectInset(zoomRect, insetWidth, insetHeight)
        
        self.map.setVisibleMapRect(insetRect, animated: true)
    }
}

extension DeliveryViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //Covered to 3 location : Restaurant, customer and driver
        let location = locations.last! as CLLocation
        self.lastLocation = location.coordinate
        
        //Create a pin annotation for driver
        if driverPin != nil {
            driverPin.coordinate = self.lastLocation
        } else {
            driverPin = MKPointAnnotation()
            driverPin.coordinate = self.lastLocation
            self.map.addAnnotation(driverPin)
        }
        
        // Reset zoom rect to cover 3 locations
        var zoomRect = MKMapRectNull
        for annotation in self.map.annotations {
            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
            let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
            zoomRect = MKMapRectUnion(zoomRect, pointRect)
        }
        
        let insetWidth = -zoomRect.size.width * 0.2
        let insetHeight = -zoomRect.size.height * 0.2
        let insetRect = MKMapRectInset(zoomRect, insetWidth, insetHeight)
        
        self.map.setVisibleMapRect(insetRect, animated: true)
    }
}
