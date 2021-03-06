//
//  Maintainer+SetsRealm.swift
//  ManaKit_Example
//
//  Created by Vito Royeca on 10/26/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import Kanna
import ManaKit
import PromiseKit
import RealmSwift

extension Maintainer {
    func createRealmSet(from dict: [String: Any]) -> Promise<Void> {
        return Promise { seal  in
            if let code = dict["code"] as? String,
                let name = dict["name"] as? String {
                    
                var set: CMSet?
                var setType: CMSetType?
                var setBlock: CMSetBlock?
                
                if let x = realm.object(ofType: CMSet.self, forPrimaryKey: code) {
                    set = x
                } else {
                    set = CMSet()
                    set!.code = code
                }
                
                set!.mtgoCode = dict["mtgo_code"] as? String
                set!.name = name
                set!.myNameSection = self.sectionFor(name: name)
                
                // setType
                if let set_type = dict["set_type"] as? String {
                    let capName = capitalize(string: self.displayFor(name: set_type))
                    
                    if let x = realm.object(ofType: CMSetType.self, forPrimaryKey: capName) {
                        setType = x
                    } else {
                        setType = CMSetType()
                        setType!.name = capName
                    }
                    
                    setType!.nameSection = self.sectionFor(name: set_type)
                    realm.add(setType!)
                }
                
                // block
                if let block = dict["block"] as? String {
                    if let x = realm.object(ofType: CMSetBlock.self, forPrimaryKey: block) {
                        setBlock = x
                    } else {
                        setBlock = CMSetBlock()
                        setBlock!.name = block
                    }
                    
                    setBlock!.code = dict["block_code"] as? String
                    setBlock!.nameSection = self.sectionFor(name: block)
                    realm.add(setBlock!)
                }
                
                // releaseDate
                if let releaseAt = dict["released_at"] as? String {
                    set!.releaseDate = releaseAt
                    set!.myYearSection = String(releaseAt.prefix(4))
                } else {
                    set!.myYearSection = "Undated"
                }
                
                if let cardCount = dict["card_count"] as? Int {
                    set!.cardCount = Int32(cardCount)
                }
                if let digital = dict["digital"] as? Bool {
                    set!.isOnlineOnly = digital
                }
                if let foilOnly = dict["foil_only"] as? Bool {
                    set!.isFoilOnly = foilOnly
                }
                if let tcgPlayerID = dict["tcgplayer_id"] as? Int {
                    set!.tcgPlayerID = Int32(tcgPlayerID)
                }
                set!.setType = setType
                set!.block = setBlock
                
                countIndex += 1
                if countIndex % self.printMilestone == 0 {
                    print("Creating sets: \(countIndex)/\(countTotal) \(Date())")
                }
                
                realm.add(set!)
                seal.fulfill(())
            }
        }
    }

    func updateRealmSet(from dict: [String: Any]) -> Promise<Void> {
        return Promise { seal  in
            if let code = dict["code"] as? String,
                let parentSetCode = dict["parent_set_code"] as? String,
                let childSet = realm.object(ofType: CMSet.self, forPrimaryKey: code),
                let parentSet = realm.object(ofType: CMSet.self, forPrimaryKey: parentSetCode) {
                
                childSet.parent = parentSet
                if let releaseDate = parentSet.releaseDate {
                    childSet.releaseDate = releaseDate
                    childSet.myYearSection = String(releaseDate.prefix(4))
                }
                
                childSet.setType = parentSet.setType
                childSet.block = parentSet.block
                print("\(parentSetCode) -> \(code)")
                
                realm.add(childSet)
            } else {
                seal.fulfill(())
            }
        }
    }
    
    func processRealmKeyruneCodes(document: HTMLDocument) -> Promise<Void> {
        return Promise { seal in
            try! realm.write {
                for div in document.xpath("//div[@class='vectors']") {
                    for span in div.xpath("//span") {
                        if let content = span.content {
                            let array = content.components(separatedBy: " ")
                            if array.count == 3 {
                                let setCode = array[1].replacingOccurrences(of: "ss-", with: "")
                                let keyruneCode = array[2].replacingOccurrences(of: "&#x", with: "").replacingOccurrences(of: ";", with: "")
                                
                                if let set = realm.object(ofType: CMSet.self, forPrimaryKey: setCode) {
                                    set.myKeyruneCode = keyruneCode
                                    realm.add(set)
                                }
                            }
                        }
                    }
                }
                seal.fulfill(())
            }
        }
    }
    
    func updateKeyruneCodes() -> Promise<Void> {
        return Promise { seal in
            try! realm.write {
                // update keyrune of children
                for set in realm.objects(CMSet.self) {
                    if let parent = set.parent {
                        set.myKeyruneCode = parent.myKeyruneCode
                        realm.add(set)
                    }
                }
                
                // manual fix
                for set in realm.objects(CMSet.self) {
                    if set.code == "c14" ||
                        set.code == "oc14" ||
                        set.code == "tc14" {
                        set.myKeyruneCode = "e65d" // typo in website
                        realm.add(set)
                     } else if set.code == "htr" ||
                            set.code == "plny" ||
                            set.code == "f11" ||
                            set.code == "f12" ||
                            set.code == "f13" ||
                            set.code == "f14" ||
                            set.code == "f15" ||
                            set.code == "f16" ||
                            set.code == "f17" ||
                            set.code == "f18" ||
                            set.code == "hho" ||
                            set.code == "j13" ||
                            set.code == "j14" ||
                            set.code == "j15" ||
                            set.code == "j16" ||
                            set.code == "j17" ||
                            set.code == "j18" ||
                            set.code == "olgc" ||
                            set.code == "pnat" ||
                            set.code == "ppro" ||
                            set.code == "pres" ||
                            set.code == "purl" ||
                            set.code == "ovnt" ||
                            set.code == "pwp11" ||
                            set.code == "pwp12" ||
                            set.code == "pwcq" ||
                            set.code == "pf19" ||
                            set.code == "j12" ||
                            set.code == "j19" ||
                            set.code == "ppp1" {
                        set.myKeyruneCode = "e687" // media insert
                        realm.add(set)
                     } else if set.code == "pal99" {
                        set.myKeyruneCode = "e622" // urza's saga
                        realm.add(set)
                     } else if set.code == "pal01" {
                        set.myKeyruneCode = "e68c" // arena
                        realm.add(set)
                     } else if set.code == "pal02" ||
                        set.code == "pal03" ||
                        set.code == "pal04" ||
                        set.code == "pal06" ||
                        set.code == "f01" ||
                        set.code == "f02" ||
                        set.code == "f03" ||
                        set.code == "f04" ||
                        set.code == "f05" ||
                        set.code == "f06" ||
                        set.code == "f07" ||
                        set.code == "f08" ||
                        set.code == "f09" ||
                        set.code == "f10" ||
                        set.code == "pgtw" ||
                        set.code == "pg07" ||
                        set.code == "pg08" ||
                        set.code == "g00" ||
                        set.code == "g01" ||
                        set.code == "g02" ||
                        set.code == "g03" ||
                        set.code == "g04" ||
                        set.code == "g05" ||
                        set.code == "g06" ||
                        set.code == "g07" ||
                        set.code == "g08" ||
                        set.code == "g09" ||
                        set.code == "g10" ||
                        set.code == "pjas" ||
                        set.code == "pjse" ||
                        set.code == "psus" ||
                        set.code == "mpr" ||
                        set.code == "pr2" ||
                        set.code == "p03" ||
                        set.code == "p04" ||
                        set.code == "p05" ||
                        set.code == "p06" ||
                        set.code == "phop" ||
                        set.code == "parc" ||
                        set.code == "p2hg" ||
                        set.code == "pwpn" ||
                        set.code == "pwp09" ||
                        set.code == "pwp10" ||
                        set.code == "pal05" {
                        set.myKeyruneCode = "e688" // dci
                        realm.add(set)
                     } else if set.code == "ana" {
                        set.myKeyruneCode = "e943" // arena league
                        realm.add(set)
                     } else if set.code == "ced" {
                        set.myKeyruneCode = "e926" // CE
                        realm.add(set)
                     } else if set.code == "dvd" ||
                        set.code == "tdvd"{
                        set.myKeyruneCode = "e66b" // divine vs demonic
                        realm.add(set)
                     } else if set.code == "gvl" ||
                        set.code == "tgvl"{
                        set.myKeyruneCode = "e66c" // garruk vs liliana
                        realm.add(set)
                     } else if set.code == "jvc" ||
                        set.code == "tjvc"{
                        set.myKeyruneCode = "e66a" // jace vs chandra
                        realm.add(set)
                     } else if set.code == "dd1" {
                        set.myKeyruneCode = "e669" // elves vs goblins
                        realm.add(set)
                     } else if set.code == "pdtp" {
                        set.myKeyruneCode = "e915" // xbox media promo
                        realm.add(set)
                     } else if set.code == "pdp12" {
                        set.myKeyruneCode = "e60f" // m13
                        realm.add(set)
                     } else if set.code == "pdp13" {
                        set.myKeyruneCode = "e610" // m14
                        realm.add(set)
                     } else if set.code == "pdp14" {
                        set.myKeyruneCode = "e611" // m15
                        realm.add(set)
                     } else if set.code == "fbb" {
                        set.myKeyruneCode = "e603" // revised / 3ed
                        realm.add(set)
                     } else if set.code == "phuk" ||
                        set.code == "psal" {
                        set.myKeyruneCode = "e909" // Salvat 2005
                        realm.add(set)
                     } else if set.code == "phpr" ||
                        set.code == "pbok" {
                        set.myKeyruneCode = "e68a" // book inserts
                        realm.add(set)
                     } else if set.code == "pi13" ||
                        set.code == "pi14" {
                        set.myKeyruneCode = "e92c" // IDW promo
                        realm.add(set)
                     } else if set.code == "cei" {
                        set.myKeyruneCode = "e927" // cei
                        realm.add(set)
                     } else if set.code == "pmoa" ||
                        set.code == "prm" {
                        set.myKeyruneCode = "e91b" // magic online
                        realm.add(set)
                     } else if set.code == "td0" {
                        set.myKeyruneCode = "e91e" // magic online deck series
                        realm.add(set)
                     } else if set.code == "ren" ||
                        set.code == "rin" {
                        set.myKeyruneCode = "e917" // rennaisance
                        realm.add(set)
                     } else if set.code == "pmps07" ||
                        set.code == "pmps08" ||
                        set.code == "pmps09" ||
                        set.code == "pmps10" ||
                        set.code == "pmps11" {
                        set.myKeyruneCode = "e919" // magic premiere shop
                        realm.add(set)
                     } else if set.code == "ps11" {
                        set.myKeyruneCode = "e90a" // Salvat 2011
                        realm.add(set)
                     } else if set.code == "sum" {
                        set.myKeyruneCode = "e605" // Summer Magic / Edgar
                        realm.add(set)
                     } else {
                        if set.myKeyruneCode == nil {
                            set.myKeyruneCode = "e684" // default '(M)'
                            realm.add(set)
                        }
                    }
                }
                
                seal.fulfill(())
            }
        }
    }
}
