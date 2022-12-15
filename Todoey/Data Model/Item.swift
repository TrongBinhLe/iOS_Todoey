//
//  Item.swift
//  Todoey
//
//  Created by admin on 14/12/2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class ItemRealm: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var createDate: Date?
    let parentCategory = LinkingObjects(fromType: CategoryRealm.self, property: "items")
}
