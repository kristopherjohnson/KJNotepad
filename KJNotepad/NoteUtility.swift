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

    class func insertNewEntityInManagedObjectContext(context: NSManagedObjectContext) -> Note {
        let note = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context) as! Note

        note.setInitialValues()

        NSLog("Created note %@", note.uuid)

        return note
    }

    class var sortByLastEditedDateDescending: NSSortDescriptor {
        return NSSortDescriptor(key: "lastEditedDate", ascending: false)
    }
    
    func setInitialValues() {
        uuid = NSUUID().UUIDString
        createdDate = NSDate()
        lastEditedDate = createdDate
        title = "New note"
        text = ""
    }
}
