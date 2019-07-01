//
//  NSManagedObjectContext + Extensions.swift
//  VirtualTourist
//
//  Created by Asmahero on ١٧ شوال، ١٤٤٠ هـ.
//  Copyright © ١٤٤٠ هـ Asmahero. All rights reserved.
//

import UIKit
import Foundation
import MapKit

extension Pin {
    //to get the value of coordinate from every lang and lat in the table
    var coordinate: CLLocationCoordinate2D {
            return CLLocationCoordinate2DMake(lat, long)
    }
    func compareIfCoorExistBefore (coordinate: CLLocationCoordinate2D) -> Bool {
        //return true if exit before in DB
        return (lat == coordinate.latitude && long == coordinate.longitude)
    }
    // we write a function for default value that we cann't anticipate like the current time, we need to put it
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
    
}
extension Photo{
    //binary data make the variable as a Data type. I will not save the image itself but the data of image relative to its type.
    func set(image: UIImage) {
        self.photo = image.pngData()
    }
    func getImage() -> UIImage? {
      //   imageData = UIImage(data: photo!)// to convert data to image to see the image
        return (photo == nil) ? nil : UIImage(data: photo!) //  if(photo == nil){return nil} else {return imageData}
    }
    // we write a function for default value that we cann't anticipate like the current time, we need to put it
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
    
}
