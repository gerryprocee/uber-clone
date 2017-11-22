//
//  RiderViewController.swift
//  Uber
//
//  Created by Gerry on 21-11-17.
//  Copyright © 2017 Gerry Procee. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import GoogleMobileAds

class RiderViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var callUberButton: UIButton!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    var userDBLocation = CLLocationCoordinate2D()
    var driverLocation = CLLocationCoordinate2D()
    var uberHasBeenCalled = false
    var driverOnTheWay = false
    let databaseName = "RideRequests"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if let email = Auth.auth().currentUser?.email {
            var ref: DatabaseReference!
            ref = Database.database().reference()
            ref.child(databaseName).queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                self.uberHasBeenCalled = true
                self.callUberButton.setTitle("Cancel Uber", for: .normal)
                ref.child(self.databaseName).removeAllObservers()
                
                if let rideRequestDict = snapshot.value as? [String:Any] {
                    if let driverLat = rideRequestDict["driverLat"] as? Double {
                        if let driverLon = rideRequestDict["driverLon"] as? Double {
                            if let riderLat = rideRequestDict["lat"] as? Double {
                                if let riderLon = rideRequestDict["lon"] as? Double {
                                    self.userDBLocation = CLLocationCoordinate2D(latitude: riderLat, longitude: riderLon)
                                    self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                                    self.driverOnTheWay = true
                                    self.displayDriverAndRider()
                                    
                                    if let email = Auth.auth().currentUser?.email {
                                        var ref: DatabaseReference!
                                        ref = Database.database().reference()
                                        ref.child(self.databaseName).queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childChanged, with: { (snapshot) in
                                            if let rideRequestDict = snapshot.value as? [String:Any] {
                                                if let driverLat = rideRequestDict["driverLat"] as? Double {
                                                    if let driverLon = rideRequestDict["driverLon"] as? Double {
                                                        self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                                                        self.driverOnTheWay = true
                                                        self.displayDriverAndRider()
                                                    }
                                                }
                                            }
                                        })
                                    }
                                }
                            }
                        }
                    }
                }
            })
        }
    }
    
    func displayDriverAndRider() {
        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
        let riderClLocation = CLLocation(latitude: userDBLocation.latitude, longitude: userDBLocation.longitude)
        //        let riderClLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        
        let distance = driverCLLocation.distance(from: riderClLocation) / 1000
        let roundedDistance = round(distance * 100) / 100
        callUberButton.setTitle("Your driver is \(roundedDistance) km away!", for: .normal)
        map.removeAnnotations(map.annotations)
        
        let latDelta = abs(driverLocation.latitude - userDBLocation.latitude) * 2 + 0.05
        let lonDelta = abs(driverLocation.longitude - userDBLocation.longitude) * 2 + 0.05
        
        let region = MKCoordinateRegion(center: userDBLocation, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
        map.setRegion(region, animated: true)
        
        let riderAnno = MKPointAnnotation()
        riderAnno.coordinate = userDBLocation
        riderAnno.title = "Your location"
        
        let driverAnno = MKPointAnnotation()
        driverAnno.coordinate = driverLocation
        driverAnno.title = "Driver's location"
        
        map.addAnnotations([riderAnno, driverAnno])
    }
    
    @IBAction func callUberTapped(_ sender: Any) {
        
        if let email = Auth.auth().currentUser?.email {
            
            if uberHasBeenCalled {
                uberHasBeenCalled = false
                callUberButton.setTitle("Call an Uber", for: .normal)
                
                var ref: DatabaseReference!
                ref = Database.database().reference()
                ref.child(databaseName).queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                    snapshot.ref.removeValue()
                    ref.child(self.databaseName).removeAllObservers()
                })
                
                // var ref: DatabaseReference!
                // ref = Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email)
                
                
            } else {
                let rideRequestDict : [String:Any] = ["email":email, "lat":userLocation.latitude, "lon":userLocation.longitude]
                uberHasBeenCalled = true
                callUberButton.setTitle("Cancel Uber", for: .normal)
                
                var ref: DatabaseReference!
                ref = Database.database().reference()
                
                ref.child(databaseName).childByAutoId().setValue(rideRequestDict)
                print("Data added to the database")
            }
        }
        
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        try? Auth.auth().signOut()
        print("Log Out succes!")
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
            let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            userLocation = center
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            map.setRegion(region, animated: true)
            map.removeAnnotations(map.annotations)
            
            if uberHasBeenCalled {
                self.displayDriverAndRider()
                
                
                
                
            } else {
                let annotation = MKPointAnnotation()
                annotation.coordinate = center
                annotation.title = "Your Location"
                map.addAnnotation(annotation)
            }
        }
    }
}
