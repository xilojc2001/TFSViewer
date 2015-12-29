//
//  TfsConfiguration+CoreDataProperties.swift
//  TFSViewer
//
//  Created by Jorge Castro on 12/25/15.
//  Copyright © 2015 Xilo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TfsConfiguration {

    @NSManaged var account: String
    @NSManaged var api: NSDecimalNumber?
    @NSManaged var password: String?
    @NSManaged var username: String?
    
}
