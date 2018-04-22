//
//  PictureTableViewController.swift
//  Photo Bucket Core Data
//
//  Created by CSSE Department on 4/16/18.
//  Copyright © 2018 Rose-Hulman. All rights reserved.
//

import UIKit
import Firebase

class PictureTableViewController: UITableViewController {
    
    var picRef: CollectionReference!
    var picListener: ListenerRegistration!
    
    var cellIdentifier = "PictureCell"
    var noCellIdentifier = "NoPictureCell"
    var showDetailSegueId = "ShowDetailSegue"
    var pictures = [WeatherPic]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(showAddDialog))
        picRef = Firestore.firestore().collection("weatherPics")
    }
    
    @objc func showAddDialog() {
        let alertController = UIAlertController(title: "Add a new Weatherpic", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Image URL or blank"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Caption"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        let createPictureAction = UIAlertAction(title: "Add Photo", style: UIAlertActionStyle.default) { (action) in
            let photoUrlTextField = alertController.textFields![0]
            let captionTextField = alertController.textFields![1]
            
            let newPicture = WeatherPic(caption: captionTextField.text!, imageUrl: photoUrlTextField.text!)
            self.picRef.addDocument(data: newPicture.data)
        }
        
        alertController.addAction(createPictureAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.pictures.removeAll()
        picListener = picRef.order(by: "caption", descending: true).limit(to: 50).addSnapshotListener({ (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                return
            }
            snapshot.documentChanges.forEach {(docChange) in
                if (docChange.type == .added) {
                    print("New quote: \(docChange.document.data())")
                    self.picAdded(docChange.document)
                } else if (docChange.type == .modified) {
                    print("Modified quote: \(docChange.document.data())")
                    self.picUpdated(docChange.document)
                } else if (docChange.type == .removed) {
                    print("Removed quote: \(docChange.document.data())")
                    self.picRemoved(docChange.document)
                }
            }
            self.pictures.sort(by: {(pic1, pic2) -> Bool in
                return pic1.caption > pic2.caption
            })
            self.tableView.reloadData()
        })
    }
    
    func picAdded(_ document: DocumentSnapshot) {
        let newPic = WeatherPic(documentSnapshot: document)
        pictures.append(newPic)
    }
    
    func picUpdated(_ document: DocumentSnapshot) {
        let modPic = WeatherPic(documentSnapshot: document)
        for pic in pictures {
            if (pic.id == modPic.id) {
                pic.caption = modPic.caption
                pic.imageUrl = modPic.imageUrl
                break
            }
        }
    }
    
    func picRemoved(_ document: DocumentSnapshot) {
        for i in 0..<pictures.count {
            if pictures[i].id == document.documentID {
                pictures.remove(at: i)
                break
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        picListener.remove()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        if pictures.count == 0 {
            super.setEditing(false, animated: animated)
        } else {
            super.setEditing(editing, animated: animated)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return max(pictures.count, 1)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if pictures.count == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: noCellIdentifier, for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            
            // Configure the cell...
            cell.textLabel?.text = pictures[indexPath.row].caption
        }
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return pictures.count > 0
    }


    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let picToDelete = pictures[indexPath.row]
            picRef.document(picToDelete.id!).delete()
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == showDetailSegueId {
            if let indexPath = tableView.indexPathForSelectedRow {
                (segue.destination as! PictureDetailViewController).picRef = picRef.document(pictures[indexPath.row].id!)
            }
        }
    }

}
