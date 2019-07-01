//
//  Singleton.swift
//  VirtualTourist
//
//  Created by Asmahero on ٢٥ شوال، ١٤٤٠ هـ.
//  Copyright © ١٤٤٠ هـ Asmahero. All rights reserved.
//

import Foundation
import UIKit
extension UIViewController{
    
    func showAlertWithOneAction(message: String) {
        // the alert view
        let alert = UIAlertController(title: "erroe", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default , handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
