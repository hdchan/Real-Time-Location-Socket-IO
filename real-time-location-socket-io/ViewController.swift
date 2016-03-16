//
//  ViewController.swift
//  real-time-location-socket-io
//
//  Created by Henry Chan on 3/15/16.
//  Copyright © 2016 Henry Chan. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    var nickname:String!
    var manager = CLLocationManager()
    var pins:[String:MKPointAnnotation] = [:]
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        manager.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleLocationsWereUpdated:", name: "locationsWereUpdated", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        askForNickname()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func askForNickname() {
        let alertController = UIAlertController(title: "SocketChat", message: "Please enter a nickname:", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addTextFieldWithConfigurationHandler(nil)
        
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
            let textfield = alertController.textFields![0]
            if textfield.text?.characters.count == 0 {
                self.askForNickname()
            }
            else {
                self.nickname = textfield.text
                
                SocketIOManager.sharedInstance.connectToServerWithNickname(self.nickname, completionHandler: { (userList) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if userList != nil {
//                            self.users = userList
                        }
                    })
                })
                
                if CLLocationManager.authorizationStatus() == .NotDetermined {
                    self.manager.requestWhenInUseAuthorization()
                } else if CLLocationManager.locationServicesEnabled() {
                    self.manager.startUpdatingLocation()
                }
            }
        }
        
        alertController.addAction(OKAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
//    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
//        if CLLocationManager.locationServicesEnabled() {
//            manager.startUpdatingLocation()
//        }
//    }
    
    func handleLocationsWereUpdated(notification: NSNotification) {
        let userList = notification.object as! [[String: AnyObject]]
//        print("got ack list")
        print(userList)
        for user in userList {
            
            let id = user["id"] as! String
            
            let lat = CLLocationDegrees(user["coordinates"]!["lat"] as! NSNumber)
            let long = CLLocationDegrees(user["coordinates"]!["long"] as! NSNumber)
            
            let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            if self.pins[id] == nil {
                let nickname = user["nickname"] as! String
                let annotation = MKPointAnnotation()
                annotation.title = nickname
                self.pins[id] = annotation
                self.mapView.addAnnotation(annotation)
            }
            
            let pin = self.pins[id]
            pin?.coordinate = coordinates
            
            
        }

    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        SocketIOManager.sharedInstance.updateUserLocation(locations[0])
    }
    
}

