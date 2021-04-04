//
//  MapViewController.swift
//  MapApp
//
//  Created by Антон Васильченко on 03.04.2021.
//

import UIKit
import GoogleMaps
import CoreLocation

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: GMSMapView!
    var marker: GMSMarker?
    var manualMarker: GMSMarker?
    var locationManager: CLLocationManager?
    let geocoder = CLGeocoder()
    
    var centerMapCoordinate:CLLocationCoordinate2D!
    
    
    let coordinates = CLLocationCoordinate2D(latitude: 59.939095, longitude: 30.315868)
    
    @IBAction func updateLocation(_ sender: Any) {
        locationManager?.startUpdatingLocation()
    }
    
    @IBAction func currentLocation(_ sender: Any) {
        locationManager?.requestLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        configureLocationManager()
        locationManager?.requestLocation()
    }
    
    func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.delegate = self
    }
    
    func configureMap() {
        let camera = GMSCameraPosition.camera(withTarget: coordinates, zoom: 17)
        mapView.camera = camera
        mapView.delegate = self
        configureMapStyle()
    }
    
    
    func placeMarkerOnCenter(centerMapCoordinate: CLLocationCoordinate2D) {
        let marker = GMSMarker()
        marker.position = centerMapCoordinate
        marker.map = mapView
    }
    
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if let manualMarker = manualMarker {
            manualMarker.position = coordinate
        } else {
            let marker = GMSMarker(position: coordinate)
            marker.map = mapView
            self.manualMarker = marker
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last
        mapView.camera = GMSCameraPosition.camera(withTarget: newLocation!.coordinate, zoom: 14.0)
        mapView.settings.myLocationButton = true
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let latitude = mapView.camera.target.latitude
        let longitude = mapView.camera.target.longitude
        centerMapCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.placeMarkerOnCenter(centerMapCoordinate: centerMapCoordinate)
    }
}
