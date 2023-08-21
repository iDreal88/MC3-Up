//
//  LocationManager.swift
//  Up
//
//  Created by David Christian on 14/08/23.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate{
    
    var locationManager = CLLocationManager()
    
    var authorisationStatus: CLAuthorizationStatus?
    
    var latitude:Double{
        locationManager.location?.coordinate.latitude ?? 37.322998
    }
    var longitude:Double{
        locationManager.location?.coordinate.longitude ?? -122.032181
    }
    
    override init(){
        super.init()
        locationManager.delegate = self
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            //location services available
            authorisationStatus = .authorizedWhenInUse
            locationManager.requestLocation()
            break
            
        case .restricted:
            authorisationStatus = .restricted
            break
            
        case .denied:
            authorisationStatus = .denied
            break
            
        case .notDetermined:
            authorisationStatus = .notDetermined
            manager.requestWhenInUseAuthorization()
            break
        
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("\(error.localizedDescription)")
    }
    
}

