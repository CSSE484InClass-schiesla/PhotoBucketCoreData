//
//  PictureTableViewController.swift
//  Photo Bucket Core Data
//
//  Created by CSSE Department on 4/16/18.
//  Copyright © 2018 Rose-Hulman. All rights reserved.
//

import UIKit
import CoreData

class PictureTableViewController: UITableViewController {
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var cellIdentifier = "PictureCell"
    var noCellIdentifier = "NoPictureCell"
    var showDetailSegueId = "ShowDetailSegue"
    var pictures = [Picture]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(showAddDialog))
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
            
            let newPicture = Picture(context: self.context)
            newPicture.pictureUrl = photoUrlTextField.text!
            newPicture.caption = captionTextField.text!
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            self.updatePictureArray()
            
            if self.pictures.count == 1 {
                self.tableView.reloadData()
            } else {
                self.tableView.insertRows(at: [IndexPath(row:0, section:0)], with: UITableViewRowAnimation.top)    }
        }
        
        alertController.addAction(createPictureAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updatePictureArray()
        tableView.reloadData()
    }
    
    func updatePictureArray() {
        let request: NSFetchRequest<Picture> = Picture.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "caption", ascending: false)]
        do {
            pictures = try context.fetch(request)
        } catch {
            fatalError("Unresolved Core Data error \(error)")
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        if pictures.count == 0 {
            super.setEditing(false, animated: animated)
        } else {
            super.setEditing(editing, animated: animated)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
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
            // Delete the row from the data source
            context.delete(pictures[indexPath.row])
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            updatePictureArray()
            
            if pictures.count == 0 {
                tableView.reloadData()
                self.setEditing(false, animated: true)
            } else {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == showDetailSegueId {
            if let indexPath = tableView.indexPathForSelectedRow {
                (segue.destination as! PictureDetailViewController).picture = pictures[indexPath.row]
            }
        }
    }

}
