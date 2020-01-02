//
//  BaseViewModel.swift
//  ManaKit
//
//  Created by Vito Royeca on 11/29/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import CoreData
import PromiseKit

open class BaseViewModel: NSObject {
    // MARK: public variables
    public var entityName = ""
    public var sortDescriptors: [NSSortDescriptor]?
    public var sectionName: String?
    public var title: String?
    public var queryString = ""
    public var searchCancelled = false
    open var predicate: NSPredicate?
    open var fetchRequest: NSFetchRequest<NSFetchRequestResult>?
    
    // MARK: private variables
    private let context = ManaKit.sharedInstance.dataStack!.viewContext
    private var _sectionIndexTitles = [String]()
    private var _sectionTitles = [String]()
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    // MARK: UITableView methods
    public func numberOfRows(inSection section: Int) -> Int {
        guard let fetchedResultsController = fetchedResultsController,
            let sections = fetchedResultsController.sections else {
            return 0
        }
        
        return sections[section].numberOfObjects
    }
    
    public func numberOfSections() -> Int {
        guard let fetchedResultsController = fetchedResultsController,
            let sections = fetchedResultsController.sections else {
                return 0
        }
        
        return sections.count
    }
    
    public func sectionIndexTitles() -> [String]? {
        return _sectionIndexTitles
    }
    
    public func sectionForSectionIndexTitle(title: String, at index: Int) -> Int {
        var sectionIndex = 0
        
        for i in 0..._sectionTitles.count - 1 {
            if _sectionTitles[i].hasPrefix(title) {
                sectionIndex = i
                break
            }
        }
        
        return sectionIndex
    }
    
    public func titleForHeaderInSection(section: Int) -> String? {
        guard let fetchedResultsController = fetchedResultsController,
            let sections = fetchedResultsController.sections else {
            return nil
        }
        
        return sections[section].name
    }
    
    // MARK: Custom methods
    public func isEmpty() -> Bool {
        guard let objects = allObjects() else {
            return true
        }
        return objects.count == 0
    }
    
    public func object(forRowAt indexPath: IndexPath) -> NSManagedObject {
        guard let fetchedResultsController = fetchedResultsController else {
            fatalError("fetchedResultsController is nil")
        }
        return fetchedResultsController.object(at: indexPath) as! NSManagedObject
    }
    
    public func allObjects() -> [NSManagedObject]? {
        guard let fetchedResultsController = fetchedResultsController else {
            return nil
        }
        return fetchedResultsController.fetchedObjects as? [NSManagedObject]
    }
    
    open func willFetchCache() -> Bool {
        return ManaKit.sharedInstance.willFetchCache(entityName,
                                                     objectFinder: nil)
    }
    
    open func deleteCache() {
        ManaKit.sharedInstance.deleteCache(entityName,
                                           objectFinder: nil)
    }
    
    open func deleteAllCache() {
        let entities = [String(describing: MGSet.self),
                        String(describing: MGCard.self)]
        
        for entity in entities {
            ManaKit.sharedInstance.deleteCache(entity,
                                               objectFinder: nil)
        }
    }
    
    open func fetchData(callback: ((_ error: Error?) -> Void)?) {
        if willFetchCache() {
            firstly {
                fetchRemoteData()
            }.compactMap { (data, result) in
                try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
            }.then { data in
                self.saveLocalData(data: data)
            }.then {
                self.fetchLocalData()
            }.done {
                if let callback = callback {
                    callback(nil)
                }
            }.catch { error in
                self.deleteCache()
                
                if let callback = callback {
                    callback(error)
                }
            }
        } else {
            firstly {
                fetchLocalData()
            }.done {
                if let callback = callback {
                    callback(nil)
                }
            }.catch { error in
                self.deleteCache()
                
                if let callback = callback {
                    callback(error)
                }
            }
        }
    }
        
    open func fetchRemoteData() -> Promise<(data: Data, response: URLResponse)> {
        let path = "/"
        
        return ManaKit.sharedInstance.createNodePromise(apiPath: path,
                                                        httpMethod: "GET",
                                                        httpBody: nil)
    }
    
    open func saveLocalData(data: [[String: Any]]) -> Promise<Void> {
        return Promise { seal in
            let completion = { (error: NSError?) in
                seal.fulfill(())
            }
            ManaKit.sharedInstance.dataStack?.sync(data,
                                                   inEntityNamed: entityName,
                                                   predicate: predicate,
                                                   operations: [.all],
                                                   completion: completion)
        }
    }
    
    open func fetchLocalData() -> Promise<Void> {
        return Promise { seal in
            if let request: NSFetchRequest<NSFetchRequestResult> = fetchRequest {
                request.predicate = predicate
                request.sortDescriptors = self.sortDescriptors
            
                self.fetchedResultsController = self.getFetchedResultsController(with: request)
                self.updateSections()
            }
            seal.fulfill(())
        }
    }
    
    open func updateSections() {
        guard let fetchedResultsController = fetchedResultsController,
            let sections = fetchedResultsController.sections else {
            return
        }
        
//        _sectionIndexTitles = [String]()
        _sectionTitles = [String]()
        
//        for set in sets {
//            if let nameSection = set.myNameSection {
//                if !_sectionIndexTitles.contains(nameSection) {
//                    _sectionIndexTitles.append(nameSection)
//                }
//            }
//        }
        
        let count = sections.count
        if count > 0 {
            for i in 0...count - 1 {
//                if let sectionTitle = sections[i].indexTitle {
//                    _sectionTitles.append(sectionTitle)
//                }
                _sectionTitles.append(sections[i].name)
            }
        }
        
        _sectionIndexTitles.sort()
        _sectionTitles.sort()
    }
    
    open func getFetchedResultsController(with fetchRequest: NSFetchRequest<NSFetchRequestResult>?) -> NSFetchedResultsController<NSFetchRequestResult> {
        var request: NSFetchRequest<NSFetchRequestResult>?
        
        if let fetchRequest = fetchRequest {
            request = fetchRequest
        } else {
            // Create a default fetchRequest
            request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            request!.predicate = predicate
            request!.sortDescriptors = sortDescriptors
        }
        
        // Create Fetched Results Controller
        let frc = NSFetchedResultsController(fetchRequest: request!,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: sectionName,
                                             cacheName: nil)
        
        // Configure Fetched Results Controller
//        frc.delegate = self
        
        // perform fetch
        do {
            try frc.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        return frc
    }
}

