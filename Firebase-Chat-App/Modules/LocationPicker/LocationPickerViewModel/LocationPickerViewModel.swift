//
//  LocationPickerViewModel.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 27.08.2024.
//

import Foundation
import CoreLocation
import MapKit

protocol LocationPickerViewModelDelegate {
    func didTappedOn(map: MKMapView, gesture: UITapGestureRecognizer)
    func addPin(to map: MKMapView)
    func didTappedSendButton(navigationController: UINavigationController?, completion: ((CLLocationCoordinate2D) -> Void)?)
}

final class LocationPickerViewModel {
    var coordinates: CLLocationCoordinate2D?
    var isPickable = true
}

extension LocationPickerViewModel: LocationPickerViewModelDelegate {
    func didTappedOn(map: MKMapView, gesture: UITapGestureRecognizer) {
        let locationInView = gesture.location(in: map)
        let coordinates = map.convert(locationInView, toCoordinateFrom: map)
        self.coordinates = coordinates
        // Drop a pin on that location
        for annotation in map.annotations {
            map.removeAnnotation(annotation)
        }
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        map.addAnnotation(pin)
    }
    
    func addPin(to map: MKMapView) {
        guard let coordinates = self.coordinates else { return }
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        map.addAnnotation(pin)
    }
    
    func didTappedSendButton(navigationController: UINavigationController?, completion: ((CLLocationCoordinate2D) -> Void)?) {
        guard let coordinates = self.coordinates else { return }
        navigationController?.popViewController(animated: true)
        completion?(coordinates)
    }
}
