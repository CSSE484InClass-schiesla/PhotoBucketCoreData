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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updatePictureArray()
        tableView.reloadData()
    }
    
    func updatePictureArray() {
        let request: NSFetchRequest<Picture> = Picture.fetchRequest()
//        request.sortDescriptors = [NSSortDescriptor(key: "created", ascending: false)]
        do {
            pictures = try context.fetch(request)
        } catch {
            fatalError("Unresolved Core Data error \(error)")
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


    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
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
