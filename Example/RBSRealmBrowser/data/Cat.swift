//
//  RealmObject2.swift
//  RBSRealmBrowser
//
//  Created by Max Baumbach on 05/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import RealmSwift

class Cat: Object {
    dynamic var catName = ""
    dynamic var age = 0
    dynamic var isTired = true
    let toys = List<Person>()
}
