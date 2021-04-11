//
//  User.swift
//  MapApp
//
//  Created by Антон Васильченко on 11.04.2021.
//

import Foundation
import RealmSwift

class User: Object {
    @objc dynamic var login = ""
    @objc dynamic var password = ""
    
    override class func primaryKey() -> String? {
        return "login"
    }
}
