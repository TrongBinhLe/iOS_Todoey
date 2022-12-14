//
//  Category.swift
//  Todoey
//
//  Created by admin on 14/12/2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class CategoryRealm: Object {
    @objc dynamic var name: String = ""
    var items = List<ItemRealm>()
}
