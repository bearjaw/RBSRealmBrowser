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
        humanNames.forEach { name in
            safeWrite { realm in
                let person = createMockPerson(named: name)
                realm.add(person)
                if let index = humanNames.firstIndex(of: name) {
                    let aCat = createMockCat(named: catNames[index])
                    aCat.toys.append(person)
                    person.aCat = aCat
                    realm.add(aCat)
                }
            }
        }
        
        let openBbi = UIBarButtonItem(title: "Open",
                                      style: .plain,
                                      target: self,
                                      action: #selector(ViewController.openBrowser
            ))
        navigationItem.rightBarButtonItem = openBbi
    }
    
    private func createMockPerson(named name: String) -> Person {
        let person = Person()
        person.personName = name
        return person
    }
    
    private  func createMockCat(named name: String) -> Cat {
        let aCat = Cat()
        aCat.catName = name
        aCat.isTired = true
        return aCat
    }
    
    private func safeWrite(inWrite: (Realm) -> Void) {
        do {
            let realm = try Realm()
            try realm.write {
                inWrite(realm)
            }
        } catch {
            NSLog("Failed creating objects \(error)")
        }
    }
    
    @objc func openBrowser() {
        // uncomment & use this line if you want to view all objects again
        //        guard let realmBrowser = RBSRealmBrowser.realmBrowser() else { return }
        
        // use this to query & display all Person objects
        guard let realmBrowser = RBSRealmBrowser.realmBrowser(showing: ["Person"]) else { return }
        present(realmBrowser, animated: true, completion: nil)
    }
    
}
