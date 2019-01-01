//
//  SetViewModel.swift
//  ManaKit_Example
//
//  Created by Jovito Royeca on 06.09.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import ManaKit
import RealmSwift

class SetViewModel: NSObject {
    // MARK: Variables
    var queryString = ""
    
    private var _set: CMSet?
    private var _sectionIndexTitles = [String]()
    private var _sectionTitles = [String]()
    private var _results: Results<CMCard>? = nil
    
    // MARK: Settings
    private let _sortDescriptors = [SortDescriptor(keyPath: "name", ascending: true),
                                    SortDescriptor(keyPath: "collectorNumber", ascending: true)]
    private var _sectionName = "myNameSection"
    
    // MARK: Overrides
    init(withSet set: CMSet) {
        super.init()
        _set = set
    }
    
    // MARK: UITableView methods
    func numberOfRows(inSection section: Int) -> Int {
        guard let results = _results else {
            return 0
        }
        
        return results.filter("\(_sectionName) == %@", _sectionTitles[section]).count
    }
    
    func numberOfSections() -> Int {
        guard let _ = _results else {
            return 0
        }
        
        return _sectionTitles.count
    }
    
    func sectionIndexTitles() -> [String]? {
        return _sectionIndexTitles
    }
    
    func sectionForSectionIndexTitle(title: String, at index: Int) -> Int {
        var sectionIndex = 0
        
        for i in 0..._sectionTitles.count - 1 {
            if _sectionTitles[i].hasPrefix(title) {
                sectionIndex = i
                break
            }
        }
        
        return sectionIndex
    }
    
    func titleForHeaderInSection(section: Int) -> String? {
        guard let _ = _results else {
            return nil
        }
        
        return _sectionTitles[section]
    }
    
    // MARK: Custom methods
    func object(forRowAt indexPath: IndexPath) -> CMCard {
        guard let results = _results else {
            fatalError("results is nil")
        }
        return results.filter("\(_sectionName) == %@", _sectionTitles[indexPath.section])[indexPath.row]
    }
    
    func objectTitle() -> String? {
        guard let set = _set else {
            return nil
        }
        return set.name
    }

    func fetchData() {
        guard let set = _set else {
            return
        }
        
        var predicate = NSPredicate(format: "set.code = %@ AND id != nil", set.code!)
        let count = queryString.count
        
        if count > 0 {
            if count == 1 {
                let newPredicate = NSPredicate(format: "name BEGINSWITH[cd] %@", queryString)
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, newPredicate])
            } else {
                let newPredicate = NSPredicate(format: "name CONTAINS[cd] %@", queryString)
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, newPredicate])
            }
        }
        
        _results = ManaKit.sharedInstance.realm.objects(CMCard.self).filter(predicate).sorted(by: _sortDescriptors)
        updateSections()
    }
    
    private func updateSections() {
        guard let results = _results else {
            return
        }
        
        _sectionIndexTitles = [String]()
        _sectionTitles = [String]()
        
//        for set in sets {
//            if let nameSection = set.myNameSection {
//                if !_sectionIndexTitles.contains(nameSection) {
//                    _sectionIndexTitles.append(nameSection)
//                }
//            }
//        }
//
//        let count = sections.count
//        if count > 0 {
//            for i in 0...count - 1 {
//                if let sectionTitle = sections[i].indexTitle {
//                    _sectionTitles.append(sectionTitle)
//                }
//            }
//        }
        
        _sectionIndexTitles.sort()
        _sectionTitles.sort()
    }
}
