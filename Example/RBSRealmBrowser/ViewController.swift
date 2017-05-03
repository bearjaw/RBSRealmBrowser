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
        
        
        let catNames = ["Garfield", "Lutz", "Squanch"]
        let humanNames = ["Morty", "Rick", "Birdperson"]
        var i = 0
        while i < 3 {
            do {
                let realm = try Realm()
                try realm.write() {
                    let person = Person()
                    person.personName = humanNames[i]
                    realm.add(person)
                    let cat = Cat()
                    person.cat = cat;
                    cat.catName = catNames[i]
                    cat.isTired = true
                    cat.toys.append(person)
                    cat.toys.append(person)
                    cat.toys.append(person)
                    person.cat = cat;
                    realm.add(cat)
                }

            }catch {
                print("failed creatimg objects")
            }
            
            i += 1
        }
        
        let bbi = UIBarButtonItem(title: "Open", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.openBrowser))
        self.navigationItem.rightBarButtonItem = bbi
    }
    
    func openBrowser(_ id: AnyObject) {
        let rb:UIViewController =  RBSRealmBrowser.realmBrowser()!
        self.present(rb, animated: true) {
        }
        
    }
    
}
