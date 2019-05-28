//
//  Item.swift
//  to-do
//
//  Created by Геннадий Дмитриев on 18/05/2019.
//  Copyright © 2019 Геннадий Дмитриев. All rights reserved.
//

import Foundation
import RealmSwift


class Task: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var userId: Int = 0
    @objc dynamic var title: String = ""
    @objc dynamic var completed: Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
