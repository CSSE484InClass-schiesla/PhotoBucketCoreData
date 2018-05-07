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
    var currentUser: String = ""
    let edit = "Edit"
    let doneEdit = "Done Editing"
    let myPhotos = "Show only my photos"
    let allPhotos = "Show all photos"
    var editActionTitle: String!
    var photoFilterActionTitle: String!
    var isEditingPicList = false
    var isShowingMyPhotos = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Menu", style: UIBarButtonItemStyle.plain, target: self, action: #selector(showActionSheetDialog))
        picRef = Firestore.firestore().collection("weatherPics")
        editActionTitle = edit
        photoFilterActionTitle = myPhotos
    }
    
    @objc func showActionSheetDialog() {
        
        let actionSheetController = UIAlertController(title: "Photo Bucket Options", message: "", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            // Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        
        let addPhotoAction = UIAlertAction(title: "Add Photo", style: .default)
        { action -> Void in
            self.showAddDialog()
        }
        actionSheetController.addAction(addPhotoAction)
        
        let editPhotoAction = UIAlertAction(title: editActionTitle, style: .default)
        { action -> Void in
            if !super.isEditing {
                self.editActionTitle = self.doneEdit
            } else {
                self.editActionTitle = self.edit
            }
            self.setEditing(!super.isEditing, animated: true)
        }
        actionSheetController.addAction(editPhotoAction)
        
        let toggleShownPhotosAction = UIAlertAction(title: photoFilterActionTitle, style: .default)
        { action -> Void in
            if (self.picListener != nil) {
                self.picListener.remove()
            }
            if !self.isShowingMyPhotos {
                self.photoFilterActionTitle = self.allPhotos
                self.showMyPhotos()
                self.isShowingMyPhotos = true
            } else {
                self.photoFilterActionTitle = self.myPhotos
                self.showAllPhotos()
                self.isShowingMyPhotos = false
            }
        }
        actionSheetController.addAction(toggleShownPhotosAction)
        
        let logOutAction = UIAlertAction(title: "Sign out", style: .destructive)
        { action -> Void in
            try! Auth.auth().signOut()
            self.appDelegate.showLoginViewController()
        }
        actionSheetController.addAction(logOutAction)
        
        self.present(actionSheetController, animated: true, completion: nil)
        
    }
    
    func showMyPhotos() {
        pictures.removeAll()
        picListener = picRef.whereField("user", isEqualTo: self.currentUser).limit(to: 50).addSnapshotListener({ (querySnapshot, error) in
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
            self.tableView.reloadData()
        })
    }
    
    func showAllPhotos() {
        pictures.removeAll()
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
            self.tableView.reloadData()
        })
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
            
            let newPicture = WeatherPic(caption: captionTextField.text!, imageUrl: photoUrlTextField.text!, user: self.currentUser)
            
            self.picRef.addDocument(data: newPicture.data)
        }
        
        alertController.addAction(createPictureAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.currentUser = Auth.auth().currentUser!.uid
        if isShowingMyPhotos {
            self.showMyPhotos()
        } else {
            self.showAllPhotos()
        }
        self.tableView.reloadData()
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
        if pictures.count > 0 {
            if pictures[indexPath.row].user == self.currentUser {
                return true
            }
        }
        return false
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
