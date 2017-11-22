//
//  AcceptViewController.swift
//  Uber
//
//  Created by Gerry on 21-11-17.
//  Copyright © 2017 Gerry Procee. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class AcceptViewController: UIViewController {
    
    @IBOutlet weak var map: MKMapView!
    
    var requestLocation = CLLocationCoordinate2D()
    var driverLocation = CLLocationCoordinate2D()
    var requestEmail = ""
    
    let databaseName = "RideRequests"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: false)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = requestLocation
        annotation.title = requestEmail
        map.addAnnotation(annotation)
        
    }
    
    @IBAction func acceptTapped(_ sender: Any) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        ref.child(self.databaseName).queryOrdered(byChild: "email").queryEqual(toValue: requestEmail).observe(.childAdded) { (snapshot) in
            snapshot.ref.updateChildValues(["driverLat":self.driverLocation.latitude, "driverLon":self.driverLocation.longitude])
            ref.child(self.databaseName).removeAllObservers()
        }
        
        // Give directions
        
        let requestCLLocation = CLLocation(latitude: requestLocation.latitude , longitude: requestLocation.longitude)
        CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count > 0 {
                    let placeMark = MKPlacemark(placemark: placemarks[0])
                    let mapItem = MKMapItem(placemark: placeMark)
                    mapItem.name = self.requestEmail
                    let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMaps(launchOptions: options)
                }
            }
        }
    }
}
