//
//  Animal.swift
//  WhatTheFoxSay
//
//  Created by Stasiuk Yaroslav on 27.10.2019.
//  Copyright © 2019 Stasiuk Yaroslav. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit
import CoreData

public class AnimalX: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var avatar: NSData?
}

extension AnimalX {
    // ❇️ The @FetchRequest property wrapper in the ContentView will call this function
    static func allIdeasFetchRequest() -> NSFetchRequest<AnimalX> {
        let request: NSFetchRequest<AnimalX> = AnimalX.fetchRequest() as! NSFetchRequest<AnimalX>
        
        // ❇️ The @FetchRequest property wrapper in the ContentView requires a sort descriptor
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
          
        return request
    }
}

struct Animal {
    var id: String
    var name: String
    var avatarURI: NSURL
    var description: String
    var imagesURI: [String]
    
//    init(json: JSON) throws {
//        id = json["id"].stringValue
//        name = json["name"].stringValue
//        // Default image
//        avatar = json["avatar"].stringValue
//    }
}
