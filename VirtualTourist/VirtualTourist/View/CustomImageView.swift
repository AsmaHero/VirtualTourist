//
//  ImageViewFunctions.swift
//  VirtualTourist
//
//  Created by Asmahero on ٢٤ شوال، ١٤٤٠ هـ.
//  Copyright © ١٤٤٠ هـ Asmahero. All rights reserved.
//

import Foundation
import UIKit
class CustomImageView: UIImageView{
    var imageVURL: URL!
    lazy var myActivityIndicator: UIActivityIndicatorView = {
        let myActivityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        self.addSubview(myActivityIndicator)
        // Position Activity Indicator in the center of the image view
        myActivityIndicator.center = self.center
        myActivityIndicator.hidesWhenStopped = true
        return myActivityIndicator
    }()
    let imagesCache = NSCache<AnyObject, AnyObject>()
    
    func ShowActivityIndicator() {
        DispatchQueue.main.async {
            self.myActivityIndicator.startAnimating()
            self.myActivityIndicator.isHidden = false
        }
    }
    func HideActivityIndicator() {
        DispatchQueue.main.async {
            self.myActivityIndicator.stopAnimating()
            self.myActivityIndicator.isHidden = true
        }
    }
    //to set a photo for the image in collection view
    func setPhoto(_ newPhoto: Photo)
    {
        if photo != nil {
            return
        }
        photo = newPhoto
    }
    //check if the image has downloaded before and has a url
    func showImageUsingCache(with url: URL!)
    {
        imageVURL = url
        //almost it has no image
        image = nil
        ShowActivityIndicator()
        //if photo url downloaded before then assign the photo url and download it as cachedImage without waiting to download it again
        if let cachedImage = imagesCache.object(forKey: url.absoluteString as NSString) as? UIImage
        {
            self.image = cachedImage
            HideActivityIndicator()
            return
        }
        //download image from online url
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard  (error == nil) else{
                print(error?.localizedDescription)
                return
            }
            guard let downloadedImage = UIImage(data: data!) else {return}
            self.imagesCache.setObject(downloadedImage, forKey: url.absoluteString as NSString)
            DispatchQueue.main.async {
                self.image = downloadedImage
                self.photo.set(image: downloadedImage)
                try? self.photo.managedObjectContext?.save()
                self.HideActivityIndicator()
            }
            
            
            
            }.resume()
    }
    var photo: Photo!{
        // willSet and didSet will never get called on setting the initial value of the property. It will only get called whenever you set the property by assigning a new value to it. It will always get called even if you assign the same value to it multiple times. didSet called if I already initialize properties of Photo class
        didSet{
            if let ImageView = photo.getImage() {
                HideActivityIndicator()
                //picViewCell has a properties of uiimageView which is image
                self.image = ImageView
                return
            }
            //if url of pic exist before just return it
            guard let ImageViewUrl = photo.photourl else{
                return
            }
            showImageUsingCache(with: ImageViewUrl)
            
        }
    }
    
    
    
}
