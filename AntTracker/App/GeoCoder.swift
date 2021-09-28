//
//  GeoCoder.swift
//  AntTracker
//
//  Created by test on 28.09.2021.
//

import Foundation
import MapKit

func getDescriptionByCoordinates(latitude: CLLocationDegrees,
                                 longitude: CLLocationDegrees,
                                 handler: @escaping (String) -> Void,
                                 fullAdress: Bool = true) {
    
    let location = CLLocation(latitude: latitude, longitude: longitude)
    
    geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
        guard error == nil else {
            return
        }
        
        // Most geocoding requests contain only one result.
        if let placemark = placemarks?.first {
            
            //construct adress string
            
            var adressArray = [String]()
            
//            if let country = placemark.country {
//                adressArray.append(country)
//            }
            
            if let admArea = placemark.administrativeArea {
                adressArray.append(admArea)
            }
            
            if let subadmArea = placemark.subAdministrativeArea {
                adressArray.append(subadmArea)
            }
            
            if let city = placemark.locality {
                adressArray.append(city)
            }
            
            if let subLoc = placemark.subLocality {
                adressArray.append(subLoc)
            }
            
            if fullAdress {
                if let street = placemark.thoroughfare {
                    adressArray.append(street)
                }
                
                if let subStreet = placemark.subThoroughfare {
                    adressArray.append(subStreet)
                }
            }
            
            adressArray = adressArray.filter { !$0.isEmpty }
            
            guard adressArray.count > 0 else {
                return
            }
            
            handler(adressArray.unique.joined(separator: ", "))
            
        }
    }
    
}
