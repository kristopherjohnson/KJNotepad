//
//  MasterViewController.swift
//  KJNotepad
//
//  Created by Kristopher Johnson on 4/24/15.
//  Copyright (c) 2015 Kristopher Johnson. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    var addButton: UIBarButtonItem? = nil
    var editButton: UIBarButtonItem? = nil

    lazy var dateFormatter: NSDateFormatter = {
        let df = NSDateFormatter()
        df.dateStyle = .ShortStyle
        df.timeStyle = .ShortStyle
        return df
        }()

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        editButton = self.editButtonItem()
        self.navigationItem.leftBarButtonItem = editButton

        addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let nc = NSNotificationCenter.defaultCenter()

        nc.addObserver(self,
            selector: "storesWillChange:",
            name: DataStoreStoresWillChangeNotification,
            object: nil)

        nc.addObserver(self,
            selector: "storesDidChange:",
            name: DataStoreStoresDidChangeNotification,
            object: nil)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func insertNewObject(sender: AnyObject) {
        let context = self.fetchedResultsController.managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!

        let newNote = Note.insertInContext(context)

        // Save the context.
        var error: NSError? = nil
        if !context.save(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                if let note = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Note {
                    let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                    controller.detailItem = note
                    controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                    controller.navigationItem.leftItemsSupplementBackButton = true
                }
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)

            var error: NSError? = nil
            if !context.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //println("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        if let note = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Note {
            cell.textLabel!.text = note.title
            cell.detailTextLabel!.text = dateFormatter.stringFromDate(note.lastEditedDate)
        }
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }

        let fetchRequest = Note.fetchRequest()
        fetchRequest.fetchBatchSize = 20

        let sortDescriptor = Note.sortByLastEditedDateDescending
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = [sortDescriptor]

        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext!,
            sectionNameKeyPath: nil,
            cacheName: "Master")
        frc.delegate = self
        _fetchedResultsController = frc

        var error: NSError? = nil
        if !_fetchedResultsController!.performFetch(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }

        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        default:
            return
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    // MARK: - iCloud

    func storesWillChange(notification: NSNotification) {
        // Disable UI
        if let editButton = self.editButton { editButton.enabled = false }
        if let addButton  = self.addButton  { addButton.enabled = false }
        if let tableView  = self.tableView  { tableView.userInteractionEnabled = false }
    }

    func storesDidChange(notification: NSNotification) {
        // Re-fetch
        var error: NSError? = nil
        fetchedResultsController.performFetch(&error)
        if let error = error {
            NSLog("%@", error.localizedDescription)
        }

        // Re-enable UI
        if let editButton = self.editButton { editButton.enabled = true }
        if let addButton  = self.addButton  { addButton.enabled = true }
        if let tableView  = self.tableView
        {
            tableView.reloadData()
            tableView.userInteractionEnabled = true
        }
    }
}

