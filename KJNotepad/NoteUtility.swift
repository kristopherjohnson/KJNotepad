//
//  Note+Utility.swift
//  KJNotepad
//
//  Created by Kristopher Johnson on 4/24/15.
//  Copyright (c) 2015 Kristopher Johnson. All rights reserved.
//

import Foundation
import CoreData

// Extension methods for Note
//
// We keep this separate from the auto-generated code in Note.swift, so
// that we can re-generate that as needed without losing this code.
extension Note {

    class var entityName: String {
        return "Note"
    }

    class func entityDescriptionInManagedObjectContext(context: NSManagedObjectContext) -> NSEntityDescription {
        return NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)!
    }

    class func insertInContext(context: NSManagedObjectContext) -> Note {
        let note = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context) as! Note

        note.setInitialValues()

        return note
    }

    private func setInitialValues() {
        uuid = NSUUID().UUIDString
        createdDate = NSDate()
        lastEditedDate = createdDate
        title = "New note"
        text = ""
    }

    class var sortByLastEditedDateDescending: NSSortDescriptor {
        return NSSortDescriptor(key: "lastEditedDate", ascending: false)
    }
    
    var uniqueKey: String {
        return uuid
    }

    class var keyPropertyName: String {
        return "uuid"
    }

    class func findByUniqueKey(uuid: String, inContext context: NSManagedObjectContext) -> Note? {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "uuid = %@", uuid)

        var error: NSError? = nil
        if let objects = context.executeFetchRequest(request, error: &error) {
            if objects.count == 1 {
                if let object = objects[0] as? Note {
                    return object
                }
            }
            else if objects.count > 1 {
                assert(false, "Should not find multiple instances with same key")
            }
        }
        else {
            assert(false, "Unexpected error on attempt to find object: \(error?.localizedDescription)")
        }

        return nil
    }

    class func fetchRequest() -> NSFetchRequest {
        return NSFetchRequest(entityName: entityName)
    }
}

