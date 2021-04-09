//
//  Marker.swift
//  MapApp
//
//  Created by Антон Васильченко on 04.04.2021.
//

import Foundation
import RealmSwift

class Marker: Object {
    @objc dynamic var created = Date()
    @objc dynamic var latitude = 0.0
    @objc dynamic var longitude = 0.0
}
