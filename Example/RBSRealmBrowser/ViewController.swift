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
        
        try! realm.write(){
            let object = RealmObject1()
            object.aProperty = "YOYO"
            realm.add(object)
            let object2 = RealmObject2()
            realm.add(object2)
        }
        
        let bbi = UIBarButtonItem(title: "Open", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ViewController.openBrowser))
        self.navigationItem.rightBarButtonItem = bbi
    }
    
    func openBrowser(id:AnyObject) {
        let rb = RBSRealmBrowser.realmBrowser()
        self.presentViewController(rb as! UIViewController, animated: true) { 
            
        }
    }

}

