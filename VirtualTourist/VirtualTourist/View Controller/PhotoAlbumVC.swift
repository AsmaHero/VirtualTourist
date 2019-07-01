//
//  PhotoAlbumVC.swift
//  VirtualTourist
//
//  Created by Asmahero on ٢١ شوال، ١٤٤٠ هـ.
//  Copyright © ١٤٤٠ هـ Asmahero. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData
import CoreLocation

class PhotoAlbumVC :  UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mesaageLabel: UILabel!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var barButton: UIBarButtonItem!
    var pin : Pin!
    var pageNumber = 1
    var hasPhotos: Bool {
        //return true if has photos
        return (fetchedResultsController.fetchedObjects?.count ?? 0) != 0
    }
    func setProcessingOn(_ ProcessingOn: Bool) {
        collectionView.isUserInteractionEnabled = !ProcessingOn
        if ProcessingOn {
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
            barButton.title = " "
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            barButton.title = "New Collection"
        }
    }
    var isFinishinDeletingAll = false
    var dataController: DataController!
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    fileprivate func setUpfetchedResultsController(){
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        // predicate to include only data were notes only related to the current notebook
        
        let sortDesciptor = NSSortDescriptor(key:"creationDate" , ascending: false)
        fetchRequest.sortDescriptors = [sortDesciptor]
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        // this way to perform fetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
            if hasPhotos {
                setProcessingOn(false)
            }
            else {
                //to be pressed automaticly without the user interaction
                barButtonTapped(self)
            }
        }
        catch{
            fatalError("the fetch could not performed: \(error.localizedDescription)")
        }
    }
    
    @IBAction func barButtonTapped(_ sender: Any) {
        setProcessingOn(true)
        if hasPhotos{
            //we have to delete all the pictures before
            isFinishinDeletingAll = true
            for photo in fetchedResultsController.fetchedObjects! {
                dataController.viewContext.delete(photo)
            }
            try? dataController.viewContext.save()
            isFinishinDeletingAll = false
        }
        ApiFilckr.getSearchPwithinBbox(with: pin.coordinate , pageNumber: pageNumber){ (urls, error, errorMessages) in
            DispatchQueue.main.async {
                self.setProcessingOn(false)
                guard (error == nil) && (errorMessages == nil) else{
                    self.showAlertWithOneAction(message: error?.localizedDescription ?? errorMessages!)
                    return
                }
                guard let urls = urls, !urls.isEmpty else{
                    self.mesaageLabel.isHidden = false
                    return
                }
                
                for url in urls {
                    let photo = Photo(context: self.dataController.viewContext)
                    photo.photourl = url
                    photo.pin = self.pin
                }
                try? self.dataController.viewContext.save()
            }
        }
        
        pageNumber += 1
    }
    

    //MARK: the frame size of the cell in collectionView in the run
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width-20) / 3 //to take the width and divide it into 3 pictures
        return CGSize(width: width, height: width)
    }

    // MARK: Collection View Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //to return the # of photos in DB
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    // to assign the data of the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // PhotoCell has to be match with the storyboard collection view cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionCell", for: indexPath) as! PhotoCollectionCell
        let photo = fetchedResultsController.object(at: indexPath)
        // to make the image of cell to have the image of photo
        cell.picViewCell.setPhoto(photo)
        return cell
    }
    // when I select the cell , it delete the selected photo at that index
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        let photo = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(photo)
        try? dataController.viewContext.save()
        
    }
    
    // MARK: Life Cycle of view controller
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mesaageLabel.isHidden = true
        setUpfetchedResultsController()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    //any transition to override the traits of its embedded child view controllers. Use the provided coordinator object to animate any changes you make.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.reloadData()
    }
    
}
extension PhotoAlbumVC:NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type != .update
        {
            //update data in collectionView
            collectionView.reloadData()
            return
        }
        if let indexPath = indexPath, type == .insert {
            collectionView.deleteItems(at: [indexPath])
            return
        }
        
        if let indexPath = indexPath, type == .delete && !isFinishinDeletingAll {
            collectionView.deleteItems(at: [indexPath])
            return
        }

        /*  // if we want to move picture later
         if let newIndexPath = newIndexPath , let oldIndexPath = indexPath {
         collectionView.moveItem(at: oldIndexPath, to: newIndexPath)
         */
    }
    
    
}

