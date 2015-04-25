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

    class func insertNewEntityInManagedObjectContext(context: NSManagedObjectContext) -> Note {
        let note = NSEntityDescription.insertNewObjectForEntityForName("Note", inManagedObjectContext: context) as! Note

        note.setDefaultValues()

        return note
    }

    func setDefaultValues() {
        createdDate = NSDate()
        lastEditedDate = createdDate
        title = "New note"
        text = ""
    }
}
