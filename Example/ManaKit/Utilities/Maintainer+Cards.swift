//
//  Maintainer+Cards.swift
//  ManaKit
//
//  Created by Jovito Royeca on 21.10.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import ManaKit
import PromiseKit

extension Maintainer {
    func fetchAllCards() -> Promise<Void> {
        return Promise { seal in
            guard let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
                fatalError("Malformed cachePath")
            }
            let cardsPath = "\(cachePath)/\(ManaKit.Constants.ScryfallDate)_\(cardsFileName)"
            let willFetch = !FileManager.default.fileExists(atPath: cardsPath)
            
            if willFetch {
                guard let urlString = "https://archive.scryfall.com/json/\(cardsFileName)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                    let url = URL(string: urlString) else {
                    fatalError("Malformed url")
                }
                var rq = URLRequest(url: url)
                rq.httpMethod = "GET"
                
                print("Fetching Scryfall cards... \(urlString)")
                firstly {
                    URLSession.shared.dataTask(.promise, with:rq)
                }.compactMap {
                    try JSONSerialization.jsonObject(with: $0.data) as? [[String: Any]]
                }.done { json in
                    if let outputStream = OutputStream(toFileAtPath: cardsPath, append: false) {
                        print("Writing Scryfall cards... \(cardsPath)")
                        var error: NSError?
                        outputStream.open()
                        JSONSerialization.writeJSONObject(json,
                                                          to: outputStream,
                                                          options: JSONSerialization.WritingOptions(),
                                                          error: &error)
                        outputStream.close()
                        print("Done!")
                    }
                    seal.fulfill(())
                }.catch { error in
                    seal.reject(error)
                }
            } else {
                seal.fulfill(())
            }
        }
    }
    
    func filterArtists(array: [[String: Any]]) -> [()->Promise<(data: Data, response: URLResponse)>] {
        var filteredData = [String]()
        
        for dict in array {
            if let artist = dict["artist"] as? String,
                !filteredData.contains(artist) {
                filteredData.append(artist)
            }
        }
        let promises: [()->Promise<(data: Data, response: URLResponse)>] = filteredData.map { artist in
            return {
                return self.createArtistPromise(artist: artist)
            }
        }
        
        return promises
    }
    
    func filterRarities(array: [[String: Any]]) -> [()->Promise<(data: Data, response: URLResponse)>] {
        var filteredData = [String]()
        
        for dict in array {
            if let rarity = dict["rarity"] as? String,
                !filteredData.contains(rarity) {
                filteredData.append(rarity)
            }
        }
        let promises: [()->Promise<(data: Data, response: URLResponse)>] = filteredData.map { rarity in
            return {
                return self.createRarityPromise(rarity: rarity)
            }
        }
        
        return promises
    }
    
    func filterLanguages(array: [[String: Any]]) -> [()->Promise<(data: Data, response: URLResponse)>] {
        var filteredData = [[String: String]]()
        
        for dict in array {
            if let lang = dict["lang"] as? String {
                var isFound = false
                
                for l in filteredData {
                    if l["code"] == lang {
                        isFound = true
                    }
                }
                if !isFound {
                    let code = lang
                    var displayCode = "null"
                    var name = "null"
                    let nameSection = sectionFor(name: name) ?? "null"
                    
                    switch code {
                    case "en":
                        displayCode = "EN"
                        name = "English"
                    case "es":
                        displayCode = "ES"
                        name = "Spanish"
                    case "fr":
                        displayCode = "FR"
                        name = "French"
                    case "de":
                        displayCode = "DE"
                        name = "German"
                    case "it":
                        displayCode = "IT"
                        name = "Italian"
                    case "pt":
                        displayCode = "PT"
                        name = "Portuguese"
                    case "ja":
                        displayCode = "JP"
                        name = "Japanese"
                    case "ko":
                        displayCode = "KR"
                        name = "Korean"
                    case "ru":
                        displayCode = "RU"
                        name = "Russian"
                    case "zhs":
                        displayCode = "CS"
                        name = "Simplified Chinese"
                    case "zht":
                        displayCode = "CT"
                        name = "Traditional Chinese"
                    case "he":
                        name = "Hebrew"
                    case "la":
                        name = "Latin"
                    case "grc":
                        name = "Ancient Greek"
                    case "ar":
                        name = "Arabic"
                    case "sa":
                        name = "Sanskrit"
                    case "px":
                        name = "Phyrexian"
                    default:
                        ()
                    }
                    filteredData.append([
                        "code": code,
                        "display_code": displayCode,
                        "name": name,
                        "name_section": nameSection
                    ])
                }
            }
        }
        let promises: [()->Promise<(data: Data, response: URLResponse)>] = filteredData.map { dict in
            return {
                return self.createLanguagePromise(code: dict["code"] ?? "null",
                                                  displayCode: dict["display_code"] ?? "null",
                                                  name: dict["name"] ?? "null")
            }
        }
        
        return promises
    }
    
    func filterWatermarks(array: [[String: Any]]) -> [()->Promise<(data: Data, response: URLResponse)>] {
        var filteredData = [String]()
        
        for dict in array {
            if let watermark = dict["watermark"] as? String,
                !filteredData.contains(watermark) {
                filteredData.append(watermark)
            }
        }
        let promises: [()->Promise<(data: Data, response: URLResponse)>] = filteredData.map { watermark in
            return {
                return self.createWatermarkPromise(name: watermark)
            }
        }
        
        return promises
    }

    func filterLayouts(array: [[String: Any]]) -> [()->Promise<(data: Data, response: URLResponse)>] {
        var filteredData = [[String: String]]()
        
        for dict in array {
            if let layout = dict["layout"] as? String {
                var isFound = false
                
                for l in filteredData {
                    if l["name"] == layout {
                        isFound = true
                    }
                }
                if !isFound {
                    let name = layout
                    var description_ = "null"
                    
                    switch name {
                    case "normal":
                        description_ = "A standard Magic card with one face"
                    case "split":
                        description_ = "A split-faced card"
                    case "flip":
                        description_ = "Cards that invert vertically with the flip keyword"
                    case "transform":
                        description_ = "Double-sided cards that transform"
                    case "meld":
                        description_ = "Cards with meld parts printed on the back"
                    case "leveler":
                        description_ = "Cards with Level Up"
                    case "saga":
                        description_ = "Saga-type cards"
                    case "adventure":
                        description_ = "Cards with an Adventure spell part"
                    case "planar":
                        description_ = "Plane and Phenomenon-type cards"
                    case "scheme":
                        description_ = "Scheme-type cards"
                    case "vanguard":
                        description_ = "Vanguard-type cards"
                    case "token":
                        description_ = "Token cards"
                    case "double_faced_token":
                        description_ = "Tokens with another token printed on the back"
                    case "emblem":
                        description_ = "Emblem cards"
                    case "augment":
                        description_ = "Cards with Augment"
                    case "host":
                        description_ = "Host-type cards"
                    case "art_series":
                        description_ = "Art Series collectable double-faced cards"
                    case "double_sided":
                        description_ = "A Magic card with two sides that are unrelated"
                    default:
                        ()
                    }
                    filteredData.append([
                        "name": name,
                        "description_": description_
                    ])
                }
            }
        }
        let promises: [()->Promise<(data: Data, response: URLResponse)>] = filteredData.map { layout in
            return {
                return self.createLayoutPromise(name: layout["name"] ?? "null",
                                                description_: layout["description_"] ?? "null")
            }
        }
        
        return promises
    }
    
    func filterFrames(array: [[String: Any]]) -> [()->Promise<(data: Data, response: URLResponse)>] {
        var filteredData = [[String: String]]()
        
        for dict in array {
            if let frame = dict["frame"] as? String {
                var isFound = false
                
                for l in filteredData {
                    if l["name"] == frame {
                        isFound = true
                    }
                }
                if !isFound {
                    let name = frame
                    var description_ = "null"
                    
                    switch name {
                    case "1993":
                        description_ = "The original Magic card frame, starting from Limited Edition Alpha."
                    case "1997":
                        description_ = "The updated classic frame starting from Mirage block."
                    case "2003":
                        description_ = "The \"modern\" Magic card frame, introduced in Eighth Edition and Mirrodin block."
                    case "2015":
                        description_ = "The holofoil-stamp Magic card frame, introduced in Magic 2015."
                    case "future":
                        description_ = "The frame used on cards from the future."
                    default:
                        ()
                    }
                    filteredData.append([
                        "name": name,
                        "description_": description_
                    ])
                }
            }
        }
        let promises: [()->Promise<(data: Data, response: URLResponse)>] = filteredData.map { layout in
            return {
                return self.createFramePromise(name: layout["name"] ?? "null",
                                               description_: layout["description_"] ?? "null")
            }
        }
        
        return promises
    }
    
    func filterFrameEffects(array: [[String: Any]]) -> [()->Promise<(data: Data, response: URLResponse)>] {
        var filteredData = [[String: String]]()
        
        for dict in array {
            if let frameEffects = dict["frame_effects"] as? [String] {
                for frameEffect in frameEffects {
                    var isFound = false
                    
                    for t in filteredData {
                        if t["id"] == frameEffect {
                            isFound = true
                        }
                    }
                    if !isFound {
                        let id = frameEffect
                        var name = "null"
                        var description_ = "null"
                        
                        switch id {
                        case "legendary":
                            name = capitalize(string: id)
                            description_ = "The cards have a legendary crown."
                        case "miracle":
                            name = capitalize(string: id)
                            description_ = "The miracle frame effect."
                        case "nyxtouched":
                            name = "Nyx-touched"
                            description_ = "The Nyx-touched frame effect."
                        case "draft":
                            name = capitalize(string: id)
                            description_ = "The draft-matters frame effect."
                        case "devoid":
                            name = capitalize(string: id)
                            description_ = "The Devoid frame effect."
                        case "tombstone":
                            name = capitalize(string: id)
                            description_ = "The Odyssey tombstone mark."
                        case "colorshifted":
                            name = capitalize(string: id)
                            description_ = "A colorshifted frame."
                        case "inverted":
                            name = capitalize(string: id)
                            description_ = "The FNM-style inverted frame."
                        case "sunmoondfc":
                            name = "Sun and Moon"
                            description_ = "The sun and moon transform marks."
                        case "compasslanddfc":
                            name = "Compass and Land"
                            description_ = "The compass and land transform marks."
                        case "originpwdfc":
                            name = "Origins and Planeswalkers"
                            description_ = "The Origins and planeswalker transform marks."
                        case "mooneldrazidfc":
                            name = "Moon and Eldrazi"
                            description_ = "The moon and Eldrazi transform marks."
                        case "waxingandwaningmoondfc":
                            name = "Waxing and Waning Crescent moon"
                            description_ = "The waxing and waning crescent moon transform marks."
                        case "showcase":
                            name = capitalize(string: id)
                            description_ = "A custom Showcase frame."
                        case "extendedart":
                            name = "Extended Art"
                            description_ = "An extended art frame."
                        default:
                            ()
                        }
                        filteredData.append([
                            "id": id,
                            "name": name,
                            "description_": description_
                        ])
                    }
                }
            }
        }
        let promises: [()->Promise<(data: Data, response: URLResponse)>] = filteredData.map { layout in
            return {
                return self.createFrameEffectPromise(id: layout["id"] ?? "null",
                                                     name: layout["name"] ?? "null",
                                                     description_: layout["description_"] ?? "null")
            }
        }
        
        return promises
    }
    
    func filterColors(array: [[String: Any]]) -> [()->Promise<(data: Data, response: URLResponse)>] {
        var filteredData = [[String: Any]]()
        
        for dict in array {
            if let colors = dict["colors"] as? [String] {
                for color in colors {
                    var isFound = false
                    
                    for t in filteredData {
                        if let s = t["symbol"] as? String,
                            s == color {
                            isFound = true
                        }
                    }
                    if !isFound {
                        let symbol = color
                        var name = "null"
                        
                        switch symbol {
                        case "B":
                            name = "Black"
                        case "G":
                            name = "Green"
                        case "R":
                            name = "Red"
                        case "U":
                            name = "Blue"
                        case "W":
                        name = "White"
                        default:
                            ()
                        }
                        filteredData.append([
                            "symbol": symbol,
                            "name": name,
                            "is_mana_color": true
                        ])
                    }
                }
            }
        }
        let promises: [()->Promise<(data: Data, response: URLResponse)>] = filteredData.map { color in
            return {
                return self.createColorPromise(symbol: color["symbol"] as? String ?? "null",
                                               name: color["name"] as? String ?? "null",
                                               isManaColor: color["is_mana_color"] as? Bool ?? false)
            }
        }
        
        return promises
    }
    
    func filterFormats(array: [[String: Any]]) -> [()->Promise<(data: Data, response: URLResponse)>] {
        var filteredData = [String]()
        
        for dict in array {
            if let legalities = dict["legalities"] as? [String: String] {
                for key in legalities.keys {
                    if !filteredData.contains(key) {
                        filteredData.append(key)
                    }
                }
            }
        }
        let promises: [()->Promise<(data: Data, response: URLResponse)>] = filteredData.map { format in
            return {
                return self.createFormatPromise(name: format)
            }
        }
        
        return promises
    }
    
    func filterLegalities(array: [[String: Any]]) -> [()->Promise<(data: Data, response: URLResponse)>] {
        var filteredData = [String]()
        
        for dict in array {
            if let legalities = dict["legalities"] as? [String: String] {
                for value in legalities.values {
                    if !filteredData.contains(value) {
                        filteredData.append(value)
                    }
                }
            }
        }
        let promises: [()->Promise<(data: Data, response: URLResponse)>] = filteredData.map { legality in
            return {
                return self.createLegalityPromise(name: legality)
            }
        }
        
        return promises
    }
    
    func filterTypes(array: [[String: Any]]) -> [()->Promise<(data: Data, response: URLResponse)>] {
        var filteredData = [[String: String]]()
        
        for dict in array {
            if let typeLine = dict["type_line"] as? String {
                for extractedType in extractTypesFrom(typeLine) {
                    var isFound = false
                    
                    if let name = extractedType["name"] {
                        for filtered in filteredData {
                            if let name2 = filtered["name"] {
                                isFound = name == name2
                                
                                if isFound {
                                    break
                                }
                            }
                        }
                        
                        if !isFound {
                            filteredData.append(extractedType)
                        }
                    }
                }
            }
        }
        
        filteredData = filteredData.sorted(by: {
            $0["parent"] ?? "" < $1["parent"] ?? ""
        })
        
        let promises: [()->Promise<(data: Data, response: URLResponse)>] = filteredData.map { type in
            return {
                return self.createCardTypePromise(name: type["name"] ?? "null",
                                                  parent: type["parent"] ?? "null")
            }
        }
        
        return promises
    }
    
    func filterComponents(array: [[String: Any]]) -> [()->Promise<(data: Data, response: URLResponse)>] {
        var filteredData = [String]()
        
        for dict in array {
            if let parts = dict["all_parts"] as? [[String: Any]] {
                for part in parts {
                    if let component = part["component"] as? String {
                        if !filteredData.contains(component) {
                            filteredData.append(component)
                        }
                    }
                }
            }
        }
        
        let promises: [()->Promise<(data: Data, response: URLResponse)>] = filteredData.map { component in
            return {
                return self.createComponentPromise(name: component)
            }
        }
        
        return promises
    }
    
    func filterFaces(array: [[String: Any]]) -> [()->Promise<(data: Data, response: URLResponse)>] {
        var promises = [()->Promise<(data: Data, response: URLResponse)>]()
        var facesArray = [[String: Any]]()
        var filteredData = [[String: Any]]()
        var cardFaceData = [[String: String]]()
        
        for dict in array {
            if let id = dict["id"] as? String,
                let faces = dict["card_faces"] as? [[String: Any]] {
             
                for i in 0...faces.count-1 {
                    let face = faces[i]
                    let faceId = "\(id)-\(face["name"] ?? "")"
                    var newFace = [String: Any]()
                    
                    for (k,v) in face {
                        newFace[k] = v
                    }
                    newFace["id"] = faceId
                    newFace["face_order"] = i
                    
                    facesArray.append(face)
                    filteredData.append(newFace)
                    cardFaceData.append(["cmcard": id,
                                         "cmcard_face": faceId])
                }
            }
        }
        
        promises.append(contentsOf: filterArtists(array: facesArray))
        promises.append(contentsOf: filterRarities(array: facesArray))
        promises.append(contentsOf: filterLanguages(array: facesArray))
        promises.append(contentsOf: filterWatermarks(array: facesArray))
        promises.append(contentsOf: filterLayouts(array: facesArray))
        promises.append(contentsOf: filterFrames(array: facesArray))
        promises.append(contentsOf: filterFrameEffects(array: facesArray))
        promises.append(contentsOf: filterColors(array: facesArray))
        promises.append(contentsOf: filterFormats(array: facesArray))
        promises.append(contentsOf: filterLegalities(array: facesArray))
        promises.append(contentsOf: filterTypes(array: facesArray))
        promises.append(contentsOf: filterComponents(array: facesArray))
        promises.append(contentsOf: filteredData.map { dict in
            return {
                return self.createCardPromise(dict: dict)
            }
        })
        promises.append(contentsOf: cardFaceData.map { face in
            return {
                return self.createFacePromise(card: face["cmcard"] ?? "null",
                                              cardFace: face["cmcard_face"] ?? "null")
            }
        })
        
        return promises
    }
    
    private func extractTypesFrom(_ typeLine: String) -> [[String: String]]  {
        var filteredTypes = [[String: String]]()
        let emdash = "\u{2014}"
        var types = [String]()
        
        if typeLine.contains("//") {
            for type in typeLine.components(separatedBy: "//") {
                let s = type.components(separatedBy: emdash)
                
                if let first = s.first,
                    let last = s.last {
                    
                    for f in first.components(separatedBy: " ") {
                        if !f.isEmpty && f != emdash {
                            let trimmed = f.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !types.contains(trimmed) {
                                types.append(trimmed)
                            }
                        }
                    }
                    
                    let trimmed = last.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !types.contains(trimmed) {
                        types.append(trimmed)
                    }
                }
            }
        } else if typeLine.contains(emdash) {
            let s = typeLine.components(separatedBy: emdash)
            
            if let first = s.first,
                let last = s.last {
                
                for f in first.components(separatedBy: " ") {
                    if !f.isEmpty && f != emdash {
                        let trimmed = f.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !types.contains(trimmed) {
                            types.append(trimmed)
                        }
                    }
                }
                
                let trimmed = last.trimmingCharacters(in: .whitespacesAndNewlines)
                if !types.contains(trimmed) {
                    types.append(trimmed)
                }
            }
        } else {
            if !types.contains(typeLine) {
                types.append(typeLine)
            }
        }
        
        types.reverse()
        for i in 0...types.count-1 {
            let type = types[i]
            var parent = "null"
            var isFound = false
            
            if type.isEmpty {
                continue
            }
            for filteredType in filteredTypes {
                if let name = filteredType["name"] {
                    isFound = name == type
                }
            }
            if !isFound {
                if i+1 <= types.count-1 {
                    parent = types[i+1]
                }
                
                filteredTypes.append([
                    "name": type,
                    "parent": parent
                ])
            }
        }
        
        return filteredTypes
    }
    
    func extractSupertypesFrom(_ typeLine: String) -> [String]  {
        let emdash = "\u{2014}"
        var types = [String]()
        
        if typeLine.contains("//") {
            for type in typeLine.components(separatedBy: "//") {
                let s = type.components(separatedBy: emdash)
                
                if let first = s.first {
                    for f in first.components(separatedBy: " ") {
                        if !f.isEmpty && f != emdash {
                            let trimmed = f.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !types.contains(trimmed) {
                                types.append(trimmed)
                            }
                        }
                    }
                }
            }
        } else if typeLine.contains(emdash) {
            let s = typeLine.components(separatedBy: emdash)
            
            if let first = s.first {
                for f in first.components(separatedBy: " ") {
                    if !f.isEmpty && f != emdash {
                        let trimmed = f.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !types.contains(trimmed) {
                            types.append(trimmed)
                        }
                    }
                }
            }
        } else {
            if !types.contains(typeLine) {
                types.append(typeLine)
            }
        }
        
        return types
    }
    
    func extractSubtypesFrom(_ typeLine: String) -> [String]  {
        let emdash = "\u{2014}"
        var types = [String]()
        
        if typeLine.contains("//") {
            for type in typeLine.components(separatedBy: "//") {
                let s = type.components(separatedBy: emdash)
                
                if let last = s.last {
                    let trimmed = last.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !types.contains(trimmed) {
                        types.append(trimmed)
                    }
                }
            }
        } else if typeLine.contains(emdash) {
            let s = typeLine.components(separatedBy: emdash)
            
            if let last = s.last {
                let trimmed = last.trimmingCharacters(in: .whitespacesAndNewlines)
                if !types.contains(trimmed) {
                    types.append(trimmed)
                }
            }
        } else {
            if !types.contains(typeLine) {
                types.append(typeLine)
            }
        }
        
        return types
    }
    
//
//    func updateCards3() -> Promise<Void> {
//        return Promise { seal in
//            let sortDescriptors = [SortDescriptor(keyPath: "set.releaseDate", ascending: true),
//                                   SortDescriptor(keyPath: "name", ascending: true)]
//            let cards = realm.objects(CMCard.self).filter("id != nil").sorted(by: sortDescriptors)
//            var count = 0
//            print("Updating cards3: \(count)/\(cards.count) \(Date())")
//
//            // reload the date
//            cachedCardTypes.removeAll()
//            for object in realm.objects(CMCardType.self) {
//                cachedCardTypes.append(object)
//            }
//
//            cachedLanguages.removeAll()
//            for object in realm.objects(CMLanguage.self) {
//                cachedLanguages.append(object)
//            }
//            let enLanguage = findLanguage(with: "en")
//
//            // update the cards
//            try! realm.write {
//                for card in cards {
//                    // displayName
//                    var displayName: String?
//                    if let language = card.language,
//                        let code = language.code {
//                        displayName = code == "en" ? card.name : card.printedName
//
//                        if displayName == nil {
//                            displayName = card.name
//                        }
//                    }
//                    card.displayName = displayName
//
//                    // myNameSection
//                    if let _ = card.id,
//                        let name = card.name {
//                        card.myNameSection = sectionFor(name: name)
//                    }
//
//                    // myNumberOrder
//                    if let _ = card.id,
//                        let collectorNumber = card.collectorNumber {
//                        card.myNumberOrder = order(of: collectorNumber)
//                    }
//
//                    // myType
//                    if let typeLine = card.typeLine,
//                        let name = typeLine.name {
//
//                        var types = [String]()
//                        for type in CardType.allCases {
//                            for n in name.components(separatedBy: " ") {
//                                let desc = type.description
//                                if n == desc && !types.contains(desc) {
//                                    types.append(desc)
//                                }
//                            }
//                        }
//
//                        if types.count == 1 {
//                            card.myType = findCardType(with: types.first!,
//                                                       language: enLanguage!)
//                        } else if types.count > 1 {
//                            card.myType = findCardType(with: "Multiple",
//                                                       language: enLanguage!)
//                        }
//                    }
//
//                    // Firebase id = set.code + _ + card.name + _ + number? + _ + languageCode
//                    if let _ = card.id,
//                        let set = card.set,
//                        let setCode = set.code,
//                        let language = card.language,
//                        let languageCode = language.code,
//                        let name = card.name {
//                        var firebaseID = "\(setCode.uppercased())_\(name)"
//
//                        let variations = realm.objects(CMCard.self).filter("set.code = %@ AND language.code = %@ AND name = %@",
//                                                                           setCode,
//                                                                           languageCode,
//                                                                           name)
//
//                        if variations.count > 1 {
//                            let orderedVariations = variations.sorted(by: {(a, b) -> Bool in
//                                return a.myNumberOrder < b.myNumberOrder
//                            })
//                            var index = 1
//
//                            for c in orderedVariations {
//                                if c.id == card.id {
//                                    firebaseID += "_\(index)"
//                                    break
//                                } else {
//                                    index += 1
//                                }
//                            }
//                        }
//
//                        // add language code for non-english cards
//                        if languageCode != "en" {
//                            firebaseID += "_\(languageCode)"
//                        }
//
//                        card.firebaseID = ManaKit.sharedInstance.encodeFirebase(key: firebaseID)
//                    }
//
//                    realm.add(card)
//
//                    count += 1
//                    if count % printMilestone == 0 {
//                        print("Updating cards3: \(count)/\(cards.count) \(Date())")
//                    }
//                }
//
//                seal.fulfill(())
//            }
//        }
//    }
    
    func cardsData() -> [[String: Any]] {
        guard let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            fatalError("Malformed cachePath")
        }
        let cardsPath = "\(cachePath)/\(ManaKit.Constants.ScryfallDate)_\(cardsFileName)"
        
        let data = try! Data(contentsOf: URL(fileURLWithPath: cardsPath))
        guard let array = try! JSONSerialization.jsonObject(with: data,
                                                            options: .mutableContainers) as? [[String: Any]] else {
            fatalError("Malformed data")
        }
        
        return array
    }
}