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
        var i = 0
        while i < 5 {
            try! realm.write() {
                let object = RealmObject1()
                object.aProperty = String(format:"Number %i", i)
                realm.add(object)
                let object2 = RealmObject2()
                object2.aProperty = String(format:"Number %i", i)
                object2.objects.append(object)
                object2.objects.append(object)
                object2.objects.append(object)
                realm.add(object2)
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
