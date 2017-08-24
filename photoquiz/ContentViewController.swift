//
//  ContentViewController.swift
//  photoquiz
//
//  Created by Roman Mikhalsky on 12.08.17.
//  Copyright © 2017 Rivne Hackathon. All rights reserved.
//

import UIKit
import Photos
import AssetsLibrary
import Firebase


class ContentViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {

    let imagePicker = UIImagePickerController()
    let locationManager = CLLocationManager()
    var image: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.imagePicker.sourceType = .camera
        } else {
            self.imagePicker.sourceType = .photoLibrary
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Take image
    @IBAction func takePhoto(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: - Done image capturing
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.imagePicker.dismiss(animated: true, completion: nil)
        self.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.delegate = self
            self.locationManager.requestLocation()
        }
        else {
            debugPrint("Location Services disabled.")
        }
    }
    
    //MARK: - Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let image = self.image else { return }
        guard let location = locations.first else { return }
        
        self.addAsset(image: image, location: location)
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint("\(error.localizedDescription)")
    }

    //MARK: - Working with final data
    func addAsset(image: UIImage, location: CLLocation) {
        debugPrint("got it!")
        
        let pathToNotApprovedPhotos = "photos_notApproved"
        
        let id = UUID().uuidString
        let storage = Storage.storage()
        let ref = storage.reference().child("\(pathToNotApprovedPhotos)/\(id).png")
        
        guard let data = image.mediumQualityJPEGNSData else { return }
        
        let uploadTask = ref.putData(data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }

            // Metadata contains file metadata such as size, content-type, and download URL.
            let storagePath = "gs://\(metadata.bucket)/\(metadata.path!)"
            
            let dict = ["id": id, "path": storagePath, "location":["lat":location.coordinate.latitude, "lon":location.coordinate.longitude]] as [String : Any]

            let ref = Database.database().reference()
            ref.child("\(pathToNotApprovedPhotos)/\(id)").setValue(dict)
        }
        uploadTask.resume()
        
    }
}
