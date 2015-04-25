//
//  Note.swift
//  KJNotepad
//
//  Created by Kristopher Johnson on 4/24/15.
//  Copyright (c) 2015 Kristopher Johnson. All rights reserved.
//

import Foundation
import CoreData

class Note: NSManagedObject {

    @NSManaged var createdDate: NSDate
    @NSManaged var lastEditedDate: NSDate
    @NSManaged var text: String
    @NSManaged var title: String

}
