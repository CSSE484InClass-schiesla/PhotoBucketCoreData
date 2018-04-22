//
//  PictureDetailViewController.swift
//  Photo Bucket Core Data
//
//  Created by CSSE Department on 4/16/18.
//  Copyright © 2018 Rose-Hulman. All rights reserved.
//

import UIKit
import Firebase

class PictureDetailViewController: UIViewController {

    var picRef: DocumentReference?
    var picListener: ListenerRegistration!
    var weatherPic: WeatherPic?
    
    @IBOutlet weak var photoCaptionLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(showEditDialog))
        // Do any additional setup after loading the view.
    }

    @objc func showEditDialog() {
        let alertController = UIAlertController(title: "Edit picture", message: "", preferredStyle: UIAlertControllerStyle.alert)
    
        alertController.addTextField { (textField) in
            textField.placeholder = "Caption"
            textField.text = self.weatherPic?.caption
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        let editPhotoAction = UIAlertAction(title: "Edit", style: UIAlertActionStyle.default) { (action) in
            let captionTextField = alertController.textFields![0]
            self.weatherPic?.caption = captionTextField.text!
            self.picRef?.setData(self.weatherPic!.data)
        }
        
        alertController.addAction(editPhotoAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        picListener = picRef?.addSnapshotListener({ (documentSnapshot, error) in
            if let error = error {
                print("Error getting the document: \(error.localizedDescription)")
                return
            }
            if !documentSnapshot!.exists {
                return
            }
            self.weatherPic = WeatherPic(documentSnapshot: documentSnapshot!)
            self.updateView()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        picListener.remove()
    }
    
    func updateView() {
        photoCaptionLabel.text = weatherPic?.caption
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let imgString = weatherPic?.imageUrl {
            if let imgUrl = URL(string: imgString) {
                DispatchQueue.global().async { // Download in the background
                    do {
                        let data = try Data(contentsOf: imgUrl)
                        DispatchQueue.main.async { // Then update on main thread
                            self.photoImageView.image = UIImage(data: data)
                        }
                    } catch {
                        print("Error downloading image: \(error)")
                    }
                }
            }
        }
    }


}
