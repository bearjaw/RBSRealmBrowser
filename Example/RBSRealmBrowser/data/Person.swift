//
//  RealmObject1.swift
//  RealmBrowser-Swift
//
//  Created by Max Baumbach on 02/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import RealmSwift

class Person: Object {

    dynamic var personName = ""
    dynamic var hungry = false
    dynamic var cat:Cat?

}
