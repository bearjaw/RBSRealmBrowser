//
//  RealmObject2.swift
//  RBSRealmBrowser
//
//  Created by Max Baumbach on 05/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import RealmSwift

class RealmObject2: Object {
    dynamic var aProperty = ""
    dynamic var aNumber = 0
    dynamic var isRealmBrowser = true
    let objects = List<RealmObject1>()
}
