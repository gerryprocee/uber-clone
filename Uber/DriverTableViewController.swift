//
//  DriverTableViewController.swift
//  Uber
//
//  Created by Gerry on 21-11-17.
//  Copyright © 2017 Gerry Procee. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class DriverTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    let databaseName = "RideRequests"
    
    var rideRequests : [DataSnapshot] = []
    var locationManager = CLLocationManager()
    var driverLocation = CLLocationCoordinate2D()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        ref.child(databaseName).observe(.childAdded) { (snapshot) in
            if let rideRequestDict = snapshot.value as? [String:Any] {
                if let driverLat = rideRequestDict["driverLat"] as? Double {
                    
                } else {
                    self.rideRequests.append(snapshot)
                    self.tableView.reloadData()
                }
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (timer) in
            self.tableView.reloadData()
        }
    }
    
    // MARK: location
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
            driverLocation = coord
        }
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        try? Auth.auth().signOut()
        print("Log Out succes!")
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return rideRequests.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "driveRequestCell", for: indexPath)

        let snapshot = rideRequests[indexPath.row]
        
        if let rideRequestDict = snapshot.value as? [String:Any] {
            if let email = rideRequestDict["email"] as? String {
                if let lat = rideRequestDict["lat"] as? Double {
                    if let lon = rideRequestDict["lon"] as? Double {
                        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                        let riderCLLocation = CLLocation(latitude: lat, longitude: lon)
                        
                        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
                        let roundedDistance = round(distance * 100) / 100
                        
                        cell.textLabel?.text = "\(email) - \(roundedDistance) km away"
                    }
                }
            }
        }
        
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = rideRequests[indexPath.row]
        performSegue(withIdentifier: "acceptSegue", sender: snapshot)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let acceptVC = segue.destination as? AcceptViewController {
            if let snapshot = sender as? DataSnapshot {
                if let rideRequestDict = snapshot.value as? [String:Any] {
                    if let email = rideRequestDict["email"] as? String {
                        if let lat = rideRequestDict["lat"] as? Double {
                            if let lon = rideRequestDict["lon"] as? Double {
                                acceptVC.requestEmail = email
                                acceptVC.requestLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                acceptVC.driverLocation = driverLocation
                            }
                        }
                    }
                }
                
            }
            
        }
    }

}
