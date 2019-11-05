//
//  Maintainer+Sets.swift
//  ManaKit_Example
//
//  Created by Jovito Royeca on 23/10/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Kanna
import ManaKit
import PromiseKit
import RealmSwift

extension Maintainer {
    func fetchSets() -> Promise<Void> {
        return Promise { seal in
            guard let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
                fatalError("Malformed cachePath")
            }
            let setsPath = "\(cachePath)/\(ManaKit.Constants.ScryfallDate)_\(setsFileName)"
            let willFetch = !FileManager.default.fileExists(atPath: setsPath)
            
            if willFetch {
                guard let urlString = "https://api.scryfall.com/sets".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                    let url = URL(string: urlString) else {
                        fatalError("Malformed url")
                }
                var rq = URLRequest(url: url)
                rq.httpMethod = "GET"
                
                print("Fetching Scryfall sets... \(urlString)")
                firstly {
                    URLSession.shared.dataTask(.promise, with:rq)
                }.compactMap {
                    try JSONSerialization.jsonObject(with: $0.data) as? [String: Any]
                }.done { json in
                    if let outputStream = OutputStream(toFileAtPath: setsPath, append: false) {
                        print("Writing Scryfall sets... \(setsPath)")
                        var error: NSError?
                        outputStream.open()
                        JSONSerialization.writeJSONObject(json,
                                                          to: outputStream,
                                                          options: JSONSerialization.WritingOptions(),
                                                          error: &error)
                        outputStream.close()
                        print("Done!")
                        seal.fulfill(())
                    }
                }.catch { error in
                    seal.reject(error)
                }
            } else {
                seal.fulfill(())
            }
        }
    }
    
    func fetchSetSymbols() -> Promise<Void> {
        return Promise { seal in
            guard let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
                fatalError("Malformed cachePath")
            }
            let keyrunePath = "\(cachePath)/\(ManaKit.Constants.ScryfallDate)_\(keyruneFileName)"
            let willFetch = !FileManager.default.fileExists(atPath: keyrunePath)
            
            if willFetch {
                guard let urlString = "http://andrewgioia.github.io/Keyrune/cheatsheet.html".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                    let url = URL(string: urlString) else {
                    fatalError("Malformed url")
                }

                var rq = URLRequest(url: url)
                rq.httpMethod = "GET"
                
                firstly {
                    URLSession.shared.downloadTask(.promise, with: rq, to: URL(fileURLWithPath: keyrunePath))
                }.done { _ in
                    seal.fulfill(())
                }.catch { error in
                    seal.reject(error)
                }
            } else {
                seal.fulfill(())
            }
        }
    }
    
    func filterSetBlocks(array: [[String: Any]]) -> [()->Promise<(data: Data, response: URLResponse)>] {
        var filteredData = [String: String]()
        
        for dict in array {
            if let blockCode = dict["block_code"] as? String,
                let block = dict["block"] as? String {
                filteredData[blockCode] = block
            }
        }
        let promises: [()->Promise<(data: Data, response: URLResponse)>] = filteredData.map { (blockCode, block) in
            return {
                return self.createSetBlockPromise(blockCode: blockCode,
                                                                block: block)
            }
        }
        return promises
    }
    
    func filterSetTypes(array: [[String: Any]]) -> [()->Promise<(data: Data, response: URLResponse)>] {
        var filteredData = [String]()
        
        for dict in array {
            if let setType = dict["set_type"] as? String,
                !filteredData.contains(setType) {
                filteredData.append(setType)
            }
        }
        let promises: [()->Promise<(data: Data, response: URLResponse)>] = filteredData.map { setType in
            return {
                return self.createSetTypePromise(setType: setType)
            }
        }
        return promises
    }
    
    func keyruneCodes() -> HTMLDocument {
        guard let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            fatalError("Malformed cachePath")
        }
        let keyrunePath = "\(cachePath)/\(ManaKit.Constants.ScryfallDate)_\(keyruneFileName)"
        let url = URL(fileURLWithPath: keyrunePath)
        
        return try! HTML(url: url, encoding: .utf8)
    }
    
    func setsData() -> [[String: Any]] {
        guard let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            fatalError("Malformed cachePath")
        }
        let setsPath = "\(cachePath)/\(ManaKit.Constants.ScryfallDate)_\(setsFileName)"
        
        let data = try! Data(contentsOf: URL(fileURLWithPath: setsPath))
        guard let dict = try! JSONSerialization.jsonObject(with: data,
                                                           options: .mutableContainers) as? [String: Any] else {
            fatalError("Malformed data")
        }
        guard let array = dict["data"] as? [[String: Any]] else {
            fatalError("Malformed data")
        }
        
        return array
    }
}
