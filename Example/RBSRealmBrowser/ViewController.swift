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
        var index = 0
        while index < 3 {
            do {
                let realm = try Realm()
                try realm.write {
                    let person = createMockPerson(named: humanNames[index])
                    realm.add(person)
                    let aCat = createMockCat(named: catNames[index])
                    aCat.toys.append(person)
                    aCat.toys.append(person)
                    aCat.toys.append(person)
                    person.aCat = aCat
                    realm.add(aCat)
                }

            } catch {
                print("failed creating objects \(error)")
            }
            
            index += 1
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
    
    @objc func openBrowser() {
        //        guard let realmBrowser = RBSRealmBrowser.realmBrowser() else { return }
        guard let realmBrowser = RBSRealmBrowser.realmBrowser(showing: ["Person"]) else { return }
        present(realmBrowser, animated: true, completion: nil)
    }
    
}
