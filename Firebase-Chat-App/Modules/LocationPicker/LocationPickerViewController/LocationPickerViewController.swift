//
//  LocationPickerViewController.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 22.08.2024.
//

import UIKit
import CoreLocation
import MapKit

class LocationPickerViewController: UIViewController {
    let map: MKMapView = {
        let map = MKMapView()
        return map
    }()
    
    var completion: ((CLLocationCoordinate2D) -> Void)?
    var coordinates: CLLocationCoordinate2D?
    var isPickable = true

    init(coordinates: CLLocationCoordinate2D?) {
        self.coordinates = coordinates
        isPickable = coordinates == nil
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isPickable {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(sendButtonTapped))
            addGestureToMap()
        }else {
            guard let coordinates = coordinates else { return }
            let pin = MKPointAnnotation()
            pin.coordinate = coordinates
            map.addAnnotation(pin)
        }
        view.backgroundColor = .systemBackground
        addSubviews()
    }
    
    func addSubviews() {
        view.addSubview(map)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        map.frame = view.bounds
    }
    
    func addGestureToMap() {
        map.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTappedMap(_:)))
        gesture.numberOfTouchesRequired = 1
        gesture.numberOfTapsRequired = 1
        map.addGestureRecognizer(gesture)
    }
    
    @objc func sendButtonTapped() {
        guard let coordinates = coordinates else { return }
        navigationController?.popViewController(animated: true)
        completion?(coordinates)
    }
    
    @objc func didTappedMap(_ gesture: UITapGestureRecognizer) {
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
}
