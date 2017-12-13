//
//  OrderViewController.swift
//  FoodApp
//
//  Created by Victor.
//  Copyright © 2017 Victor. All rights reserved.
//

import UIKit
import SwiftyJSON
import MapKit

class OrderViewController: UIViewController {
    
    @IBOutlet weak var menuBarBtn: UIBarButtonItem!
    @IBOutlet weak var tbvMeals: UITableView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var lbStatus: UILabel!
    
    var tray = [JSON]()
    
    var destination: MKPlacemark?
    var source: MKPlacemark?
    
    var driverPin: MKPointAnnotation!
    var timer = Timer()
    
    lazy var myDispatchQueue: DispatchQueue = {
        let queue = DispatchQueue.global(qos: .userInitiated)
        return queue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuBarBtn.target = self.revealViewController()
            menuBarBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        myDispatchQueue.async { self.getLatestOrder() }
        self.tbvMeals.reloadData()
    }
    
    func getLatestOrder() {
        
        APIManager.shared.getLatestOrder { (json) in
            let order = json["order"]
            if order["status"] != nil {
                if let orderDetails = order["order_details"].array {
                    self.lbStatus.text = order["status"].string!.uppercased()
                    self.tray = orderDetails
                    self.tbvMeals.reloadData()
                }
                
                let from = order["restaurant"]["address"].string!
                let to = order["address"].string!
                
                self.getLocation(from, "Restaurant", { (sou) in
                    
                    self.source = sou
                    self.getLocation(to, "Customer", { (des) in
                        self.destination = des
                        self.getDirections()
                    })
                })
                
                if order["status"] != "Delivered" {
                    self.setTimer()
                }
            }
            
        }
    }
    
    
    @objc func getDriverLocation(_ sender: AnyObject) {
        APIManager.shared.getDriverLocation { (json) in
            if let location = json["location"].string {
                self.lbStatus.text = "В ПУТИ"
                
                let split = location.components(separatedBy: ",")
                let latitude = Double(split[0])!
                let longitude = Double(split[1])!
                
                print("lat=\(latitude) ; lng=\(longitude)")
                let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
                
                
                //Create a pin annotation for driver
                if self.driverPin != nil {
                    self.driverPin.coordinate = coordinate
                } else {
                    self.driverPin = MKPointAnnotation()
                    self.driverPin.coordinate = coordinate
                    self.driverPin.title = "DRY"  //////-----++++++++++
                    self.map.addAnnotation(self.driverPin)
                }
                
                // Reset zoom rect to cover 3 locations
                self.autoZoom()
                
            } else {
                self.timer.invalidate()
            }
        }
    }
    
    func autoZoom() {
        
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
    
    
    func setTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(getDriverLocation(_:)),
            userInfo: nil,
            repeats: true)
    }
    
    
}

extension OrderViewController: MKMapViewDelegate {
    
    // #1 - Delegate method of MKMapViewDelegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = #colorLiteral(red: 0.9088872671, green: 0.246530652, blue: 0.4369201064, alpha: 1)//UIColor.blue
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
    
    //#5 - Customize pin point with image
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationIdentifier = "MyPin"
        var annotationView: MKAnnotationView?
        if let dequeueAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeueAnnotationView
            annotationView?.annotation = annotation
        } else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        }
        
        if let annotationView = annotationView, let name = annotation.title! {
            
            switch name {
            case "DRI":
                annotationView.canShowCallout = true
                annotationView.image = UIImage(named: "pin_car")
            case "RES":
                annotationView.canShowCallout = true
                annotationView.image = UIImage(named: "pin_restaurant")
            case "CUS":
                annotationView.canShowCallout = true
                annotationView.image = UIImage(named: "pin_customer")
            default:
                annotationView.canShowCallout = true
                annotationView.image = UIImage(named: "pin_car")
            }
        }
        return annotationView
    }
}

extension OrderViewController: UITableViewDelegate {}

extension OrderViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tray.count
    }
    
    func tableView (_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "OrderItemCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! OrderViewCell//OrderViewCell
        
        let item = tray[indexPath.row]
        cell.lbQty.text = String(item["quantity"].int!)
        cell.lbMealName.text = item["meal"]["name"].string
        cell.lbSubTotal.text = "₽\(String(item["sub_total"].float!))"
        
        return cell
    }
}


