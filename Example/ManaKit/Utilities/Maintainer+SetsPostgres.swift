//
//  Maintainer+SetsPostgres.swift
//  ManaKit_Example
//
//  Created by Vito Royeca on 10/26/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import Kanna
import ManaKit
import PromiseKit

extension Maintainer {
    func createSetBlockPromise(blockCode: String, block: String) -> Promise<(data: Data, response: URLResponse)> {
        let name_section = self.sectionFor(name: block) ?? "null"
        let parameters = """
                         code=\(blockCode)&
                         name=\(block)&
                         name_section=\(name_section)
                         """
        let urlString = "\(ManaKit.Constants.APIURL)/setblocks"
        
        return createNodePromise(urlString: urlString, parameters: parameters)
    }

    func createSetTypePromise(setType: String) -> Promise<(data: Data, response: URLResponse)> {
        let capName = capitalize(string: self.displayFor(name: setType))
        let name_section = self.sectionFor(name: setType) ?? "null"
        let parameters = """
                         name=\(capName)&
                         name_section=\(name_section)
                         """
        let urlString = "\(ManaKit.Constants.APIURL)/settypes"
                
        return createNodePromise(urlString: urlString, parameters: parameters)
    }
    
    func createSetPromise(dict: [String: Any]) -> Promise<(data: Data, response: URLResponse)> {
        let card_count = dict["card_count"] ?? 0
        let code = dict["code"] ?? "null"
        let is_foil_only = dict["foil_only"] ?? false
        let is_online_only = dict["digital"] ?? false
        let mtgo_code = dict["mtgo_code"] ?? "null"
        let my_keyrune_code = "e684"
        var my_name_section = "null"
        if let name = dict["name"] as? String {
            my_name_section = self.sectionFor(name: name) ?? "null"
        }
        var myYearSection = "Undated"
        if let releaseDate = dict["released_at"] as? String {
            myYearSection = String(releaseDate.prefix(4))
        }
        let name = dict["name"] ?? "null"
        let releaseDate = dict["released_at"] ?? "null"
        let tcgplayer_id = dict["tcgplayer_id"] ?? 0
        let cmsetblock = dict["block_code"] ?? "null"
        var set_type_cap = "null";
        if let set_type = dict["set_type"] as? String {
            set_type_cap = capitalize(string: self.displayFor(name: set_type))
        }
        let cmset_parent = dict["parent_set_code"] ?? "null"
        let parameters = """
                         card_count=\(card_count)&
                         code=\(code)&
                         is_foil_only=\(is_foil_only)&
                         is_online_only=\(is_online_only)&
                         mtgo_code=\(mtgo_code)&
                         my_keyrune_code=\(my_keyrune_code)&
                         my_name_section=\(my_name_section)&
                         my_year_section=\(myYearSection)&
                         name=\(name)&
                         release_date=\(releaseDate)&
                         tcgplayer_id=\(tcgplayer_id)&
                         cmsetblock=\(cmsetblock)&
                         cmsettype=\(set_type_cap)&
                         cmset_parent=\(cmset_parent)
                         """
        let urlString = "\(ManaKit.Constants.APIURL)/sets"
        
        return createNodePromise(urlString: urlString, parameters: parameters)
    }
    
    func createKeyrunePromises(array: [[String: Any]]) -> [()->Promise<(data: Data, response: URLResponse)>] {
        let document = keyruneCodes()
        var keyrunes = [String: String]()
        
        for div in document.xpath("//div[@class='vectors']") {
            for span in div.xpath("//span") {
                if let content = span.content {
                    let components = content.components(separatedBy: " ")
                    if components.count == 3 {
                        let setCode = components[1].replacingOccurrences(of: "ss-", with: "")
                        let keyruneCode = components[2].replacingOccurrences(of: "&#x", with: "").replacingOccurrences(of: ";", with: "")
                        keyrunes[setCode] = keyruneCode
                    }
                }
            }
        }
        
        var promises: [()->Promise<(data: Data, response: URLResponse)>] = keyrunes.map { (setCode, keyruneCode) in
            return {
                return self.createKeyruneCodePromise(code: setCode,
                                                               keyruneCode: keyruneCode)
            }
        }
        
        keyrunes = updatableKeyruneCodes(array: array)
        promises.append(contentsOf: keyrunes.map { (setCode, keyruneCode) in
            return {
                return self.createKeyruneCodePromise(code: setCode,
                                                               keyruneCode: keyruneCode)
            }
        })
        
        return promises
    }
    
    func updatableKeyruneCodes(array: [[String: Any]]) -> [String: String] {
        var keyruneCodes = [String: String]()
        
        // manual fix
        for dict in array {
            if let code = dict["code"] as? String {
                if code == "c14" ||
                    code == "oc14" ||
                    code == "tc14" {
                    keyruneCodes[code] = "e65d" // typo in website
                 } else if code == "htr" ||
                    code == "plny" ||
                    code == "f11" ||
                    code == "f12" ||
                    code == "f13" ||
                    code == "f14" ||
                    code == "f15" ||
                    code == "f16" ||
                    code == "f17" ||
                    code == "f18" ||
                    code == "hho" ||
                    code == "j13" ||
                    code == "j14" ||
                    code == "j15" ||
                    code == "j16" ||
                    code == "j17" ||
                    code == "j18" ||
                    code == "olgc" ||
                    code == "pnat" ||
                    code == "ppro" ||
                    code == "pres" ||
                    code == "purl" ||
                    code == "ovnt" ||
                    code == "pwp11" ||
                    code == "pwp12" ||
                    code == "pwcq" ||
                    code == "pf19" ||
                    code == "j12" ||
                    code == "j19" ||
                    code == "ppp1" {
                    keyruneCodes[code] = "e687"  // media insert
                 } else if code == "pal99" {
                    keyruneCodes[code] = "e622"  // urza's saga
                 } else if code == "pal01" {
                    keyruneCodes[code] = "e68c"  // arena
                 } else if code == "pal02" ||
                    code == "pal03" ||
                    code == "pal04" ||
                    code == "pal06" ||
                    code == "f01" ||
                    code == "f02" ||
                    code == "f03" ||
                    code == "f04" ||
                    code == "f05" ||
                    code == "f06" ||
                    code == "f07" ||
                    code == "f08" ||
                    code == "f09" ||
                    code == "f10" ||
                    code == "pgtw" ||
                    code == "pg07" ||
                    code == "pg08" ||
                    code == "g00" ||
                    code == "g01" ||
                    code == "g02" ||
                    code == "g03" ||
                    code == "g04" ||
                    code == "g05" ||
                    code == "g06" ||
                    code == "g07" ||
                    code == "g08" ||
                    code == "g09" ||
                    code == "g10" ||
                    code == "pjas" ||
                    code == "pjse" ||
                    code == "psus" ||
                    code == "mpr" ||
                    code == "pr2" ||
                    code == "p03" ||
                    code == "p04" ||
                    code == "p05" ||
                    code == "p06" ||
                    code == "phop" ||
                    code == "parc" ||
                    code == "p2hg" ||
                    code == "pwpn" ||
                    code == "pwp09" ||
                    code == "pwp10" ||
                    code == "pal05" {
                    keyruneCodes[code] = "e688"  // dci
                 } else if code == "ana" {
                    keyruneCodes[code] = "e943"  // arena league
                 } else if code == "ced" {
                    keyruneCodes[code] = "e926"  // CE
                 } else if code == "dvd" ||
                    code == "tdvd"{
                    keyruneCodes[code] = "e66b" // divine vs demonic
                 } else if code == "gvl" ||
                    code == "tgvl"{
                    keyruneCodes[code] = "e66c"  // garruk vs liliana
                 } else if code == "jvc" ||
                    code == "tjvc"{
                    keyruneCodes[code] = "e66a"  // jace vs chandra
                 } else if code == "dd1" {
                    keyruneCodes[code] = "e669"  // elves vs goblins
                 } else if code == "pdtp" {
                    keyruneCodes[code] = "e915"  // xbox media promo
                 } else if code == "pdp12" {
                    keyruneCodes[code] = "e60f"  // m13
                 } else if code == "pdp13" {
                    keyruneCodes[code] = "e610"  // m14
                 } else if code == "pdp14" {
                    keyruneCodes[code] = "e611"  // m15
                 } else if code == "fbb" {
                    keyruneCodes[code] = "e603"  // revised / 3ed
                 } else if code == "phuk" ||
                    code == "psal" {
                    keyruneCodes[code] = "e909"  // Salvat 2005
                 } else if code == "phpr" ||
                    code == "pbok" {
                    keyruneCodes[code] = "e68a"  // book inserts
                 } else if code == "pi13" ||
                    code == "pi14" {
                    keyruneCodes[code] = "e92c"  // IDW promo
                 } else if code == "cei" {
                    keyruneCodes[code] = "e927"  // cei
                 } else if code == "pmoa" ||
                    code == "prm" {
                    keyruneCodes[code] = "e91b"  // magic online
                 } else if code == "td0" {
                    keyruneCodes[code] = "e91e"  // magic online deck series
                 } else if code == "ren" ||
                    code == "rin" {
                    keyruneCodes[code] = "e917"  // rennaisance
                 } else if code == "pmps07" ||
                    code == "pmps08" ||
                    code == "pmps09" ||
                    code == "pmps10" ||
                    code == "pmps11" {
                    keyruneCodes[code] = "e919"  // magic premiere shop
                 } else if code == "ps11" {
                    keyruneCodes[code] = "e90a"  // Salvat 2011
                 } else if code == "sum" {
                    keyruneCodes[code] = "e605"  // Summer Magic / Edgar
                 }
            }
        }
            
        return keyruneCodes
    }
    
    private func createKeyruneCodePromise(code: String, keyruneCode: String) -> Promise<(data: Data, response: URLResponse)> {
        let parameters = "my_keyrune_code=\(keyruneCode)"
        let urlString = "\(ManaKit.Constants.APIURL)/sets/updatekeyrune/\(code)"
        
        return createNodePromise(urlString: urlString, parameters: parameters)
    }
}
