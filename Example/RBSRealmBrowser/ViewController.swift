//
//  ViewController.swift
//  RBSRealmBrowser
//
//  Created by Max Baumbach on 04/02/2016.
//  Copyright (c) 2016 Max Baumbach. All rights reserved.
//

import UIKit
import RBSRealmBrowser
import RealmSwift


class ViewController: UIViewController {

    private var sampleView = SampleView()

    override func loadView() {
        self.view = sampleView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let realm = try! Realm()
        let catNames = ["Garfield", "Lutz", "Squanch"]
        let humanNames = ["Morty", "Rick", "Birdperson"]
        
        var i = 0
        while i < 3 {
            try! realm.write() {
                let person = Person()
                person.personName = humanNames[i]
                realm.add(person)
                let cat = Cat()
                cat.catName = catNames[i]
                cat.isTired = true
                cat.toys.append(person)
                cat.toys.append(person)
                cat.toys.append(person)
                realm.add(cat)
            }
            i += 1
        }


        let bbi = UIBarButtonItem(title: "Open", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.openBrowser))
        self.navigationItem.rightBarButtonItem = bbi
    }

    func openBrowser(_ id: AnyObject) {
        let rb = RBSRealmBrowser.realmBrowser()
        self.present(rb as! UIViewController, animated: true) {

        }
    }

}
