//
//  RealmObject1.swift
//  RealmBrowser-Swift
//
//  Created by Max Baumbach on 02/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import RealmSwift

class Person: Object {

    @objc dynamic var personName = ""
    @objc dynamic var hungry = false
    @objc dynamic var aCat: Cat?

}
