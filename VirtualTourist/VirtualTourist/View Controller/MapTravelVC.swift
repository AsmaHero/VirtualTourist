//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Asmahero on ١٥ شوال، ١٤٤٠ هـ.
//  Copyright © ١٤٤٠ هـ Asmahero. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

class MapTravelVC: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate {
    //MARK: OUTLETS
    var locationCoordinate: CLLocationCoordinate2D!
    let newPin = MKPointAnnotation()
        @IBOutlet weak var MapView: MKMapView!
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    // to give it a type of DataController it self
    var dataController: DataController!
    
    fileprivate func setUpfetchedResultsController(){
        /// from here the code of request, all requests must be sorted
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        // filter data
        let sortDesciptor = NSSortDescriptor(key:"creationDate" , ascending: false)
        fetchRequest.sortDescriptors = [sortDesciptor]
        
        // this way to perform fetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
            AddAnnotationsToMapView()

        }
        catch{
            fatalError("the fetch could not performed: \(error.localizedDescription)")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // add gesture recognizer
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.mapLongPress(_:))) // colon needs to pass through info
        longPress.minimumPressDuration = 1.5 // in seconds
        //add gesture recognition
        MapView.addGestureRecognizer(longPress)
        MapView.delegate = self
        setUpfetchedResultsController()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Users will be able to zoom and scroll around the map using standard pinch and drag gestures.
        //zoom
        MapView.isZoomEnabled = true
        MapView.isScrollEnabled = true
        setUpfetchedResultsController()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //MARK: When the pin is tapped it is navigated to photosVC
        //to check all the data in pin DB then filter it and take the wanted value that i selected it. AND TAKE THAT pin
        let pin = fetchedResultsController.fetchedObjects?.filter {
            $0.compareIfCoorExistBefore(coordinate: view.annotation!.coordinate)}.first!
        performSegue(withIdentifier: "ShowPhotos", sender: pin)
        
    }
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        UserDefaults.standard.double(forKey: "lon")
        UserDefaults.standard.double(forKey: "lat")
        let lonUserDefault = userLocation.coordinate.longitude
        let latUserDefault = userLocation.coordinate.latitude
        UserDefaults.standard.set(lonUserDefault, forKey: "lon")
        UserDefaults.standard.set(latUserDefault, forKey: "lat")
        
    }
    
    func AddAnnotationsToMapView() {
        //to make sure the DB IS NOT EMPTY
        guard let pins = fetchedResultsController.fetchedObjects else{ return }
        for pin in pins {
            //to make sure the pin is loaded before. If it existed before in the DB before then continue to add it from the DB
            if MapView.annotations.contains(where:{ pin.compareIfCoorExistBefore(coordinate: $0.coordinate)}) {
                continue
            }
            let newPin = MKPointAnnotation()
            newPin.coordinate = pin.coordinate
            newPin.title = "Asma Alkaldi"
            MapView.addAnnotation(newPin)
        }
    }
    // func called when gesture recognizer detects a long press
    @objc func mapLongPress(_ recognizer: UIGestureRecognizer) {
     //   print("A long press has been detected.")
        
        let touchedAt = recognizer.location(in: self.MapView) // adds the location on the view it was pressed
        let touchedAtCoordinate : CLLocationCoordinate2D = MapView.convert(touchedAt, toCoordinateFrom: self.MapView) // will get coordinates
        /// beginning line of adding function
        let pin = Pin(context: dataController.viewContext)
        pin.long = touchedAtCoordinate.longitude
        pin.lat = touchedAtCoordinate.latitude
        pin.creationDate = Date()
        try? dataController.viewContext.save()
       // print("it has been saved")
        
    }

    // here is to identify the shape of your pin, how it looks like
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotos"
        {
            let photosVC = segue.destination as! PhotoAlbumVC
            photosVC.pin = sender as? Pin
            photosVC.dataController = dataController
        }
    }
}

extension MapTravelVC:NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            AddAnnotationsToMapView()
            break
        case .delete:
            MapView.removeAnnotation(newPin)
            break
        case .update:
            break
        case .move:
            break
            
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        MapView.updateFocusIfNeeded()
    }
    
    
}

