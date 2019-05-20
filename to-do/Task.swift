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
    @objc dynamic var title: String = ""
    @objc dynamic var completed: Bool = false
}
