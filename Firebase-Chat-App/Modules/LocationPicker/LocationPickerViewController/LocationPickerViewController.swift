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
    let locationPickerViewModel = LocationPickerViewModel()
    
    let map: MKMapView = {
        let map = MKMapView()
        return map
    }()
    
    var completion: ((CLLocationCoordinate2D) -> Void)?

    init(coordinates: CLLocationCoordinate2D?) {
        locationPickerViewModel.coordinates = coordinates
        locationPickerViewModel.isPickable = coordinates == nil
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if locationPickerViewModel.isPickable {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(sendButtonTapped))
            addGestureToMap()
        }else {
            locationPickerViewModel.addPin(to: map)
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
        locationPickerViewModel.didTappedSendButton(navigationController: navigationController, completion: completion)
    }
    
    @objc func didTappedMap(_ gesture: UITapGestureRecognizer) {
        locationPickerViewModel.didTappedOn(map: self.map, gesture: gesture)
    }
}
