//
//  MapViewController.swift
//  MapApp
//
//  Created by Антон Васильченко on 03.04.2021.
//

import UIKit
import GoogleMaps
import CoreLocation
import RealmSwift
import RxCocoa
import RxSwift

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: GMSMapView!
    var marker: GMSMarker?
    var manualMarker: GMSMarker?
    let geocoder = CLGeocoder()
    let realm = try! Realm()
    var trackStatus = false
    var realmMarkers: [Marker] = []
    var bounds = GMSCoordinateBounds()
    var route: GMSPolyline?
    var routePath: GMSMutablePath?
    
    let locationManager = LocationManager.instance
    let disposeBag = DisposeBag()
    
    var centerMapCoordinate:CLLocationCoordinate2D!
    
    
    let coordinates = CLLocationCoordinate2D(latitude: 59.939095, longitude: 30.315868)
    
    @IBAction func currentLocation(_ sender: Any) {
        locationManager.requestLocation()
    }
    
    @IBAction func startTrackTapped(_ sender: Any) {
        trackStatus = true
        mapView.clear()
        updateUserLocation()
        locationManager.startUpdateingLocation()
    }
    
    @IBAction func endTrackTapped(_ sender: Any) {
        trackStatus = false
        
        let oldMarkers = realm.objects(Marker.self)
        try! realm.write {
            realm.delete(oldMarkers)
            realm.add(realmMarkers)
        }
        
        realmMarkers = []
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func showTrack (_ sender: Any) {
        if trackStatus == true {
            let alert = UIAlertController(title: "Track status", message: "Need to stop tracking", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
                showTrackOnMap()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            showTrackOnMap()
            
        }
    }
    
    func showTrackOnMap() {
        trackStatus = false
        mapView.clear()
        realmMarkers = []
        let realm = try! Realm()
        realmMarkers.append(contentsOf: realm.objects(Marker.self))
        for x in realmMarkers {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2DMake(x.latitude, x.longitude)
            marker.map = mapView
            bounds = bounds.includingCoordinate(marker.position)
        }
        
        mapView.setMinZoom(1, maxZoom: 15)
        let update = GMSCameraUpdate.fit(bounds, withPadding: 50)
        mapView.animate(with: update)
        mapView.setMinZoom(1, maxZoom: 20)
        realmMarkers = []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        configureLocationManager()
        locationManager.requestLocation()
        print(realm.configuration.fileURL!)
    }
    
    func updateUserLocation() {
        route?.map = nil
        route = GMSPolyline()
        routePath = GMSMutablePath()
        route?.map = mapView
        locationManager.startUpdateingLocation()
    }
    
    func configureLocationManager() {
        _ = locationManager
            .location
            .asObservable()
            .bind { [weak self] location in
                guard let location = location else { return }
                self?.routePath?.add(location.coordinate)
                self?.route?.path = self?.routePath
                self?.placeMarkerOnCenter(position: location.coordinate)
                self?.configureMap()
                
                let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17)
                self?.mapView.animate(to: position)
            }
    }
    
    func configureMap() {
        let camera = GMSCameraPosition.camera(withTarget: coordinates, zoom: 17)
        mapView.camera = camera
        configureMapStyle()
    }
    
    
    func placeMarkerOnCenter(position: CLLocationCoordinate2D) {
        if trackStatus == true {
            let date = Date()
            let formatter = DateFormatter()
            let marker = GMSMarker()
            formatter.dateFormat = "dd.MM.yyyy HH:MM"
            marker.position = position
            marker.map = mapView
            mapView.animate(toLocation: position)
            let realmMarker = Marker()
            realmMarker.latitude = position.latitude
            realmMarker.longitude = position.longitude
            realmMarker.created = date
            realmMarkers.append(realmMarker)
        }
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

