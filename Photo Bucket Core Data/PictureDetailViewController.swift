//
//  PictureDetailViewController.swift
//  Photo Bucket Core Data
//
//  Created by CSSE Department on 4/16/18.
//  Copyright © 2018 Rose-Hulman. All rights reserved.
//

import UIKit

class PictureDetailViewController: UIViewController {

    var picture: Picture?
    
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
            textField.text = self.picture?.caption
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        let createPhotoAction = UIAlertAction(title: "Edit", style: UIAlertActionStyle.default) { (action) in
            let captionTextField = alertController.textFields![0]
            self.picture?.caption = captionTextField.text!
            self.updateView()
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
        }
        
        alertController.addAction(createPhotoAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
    }
    
    func updateView() {
        photoCaptionLabel.text = picture?.caption
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let imgString = picture?.pictureUrl {
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
