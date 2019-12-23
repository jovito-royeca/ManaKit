//
//  ServerInfoViewModel.swift
//  ManaKit
//
//  Created by Vito Royeca on 12/7/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import CoreData
import PromiseKit

public class ServerInfoViewModel: BaseViewModel {
    // MARK: Variables
    var _fetchRequest: NSFetchRequest<NSFetchRequestResult>?
    override public var fetchRequest: NSFetchRequest<NSFetchRequestResult>? {
        get {
            if _fetchRequest == nil {
                _fetchRequest = MGServerInfo.fetchRequest()
            }
            return _fetchRequest
        }
        set {
            _fetchRequest = newValue
        }
    }
    
    // MARK: Initialization
    override public init() {
        super.init()
        
        entityName = String(describing: MGServerInfo.self)
        sortDescriptors = [NSSortDescriptor(key: "scryfallVersion", ascending: true)]
    }

    // MARK: Overrides
    override public func fetchRemoteData() -> Promise<(data: Data, response: URLResponse)> {
        let urlString = "\(ManaKit.Constants.APIURL)/serverinfo"
        
        return ManaKit.sharedInstance.createNodePromise(urlString: urlString,
                                                        httpMethod: "GET",
                                                        httpBody: nil)
    }
}