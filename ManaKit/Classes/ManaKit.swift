//
//  Manakit.swift
//  ManaKit
//
//  Created by Jovito Royeca on 11/04/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import UIKit
import Kanna
import PromiseKit
import SDWebImage
import SSZipArchive
import Sync


@objc(ManaKit)
public class ManaKit: NSObject {
    public enum Fonts {
        public static let preEightEdition      = UIFont(name: "Magic:the Gathering", size: 17.0)
        public static let preEightEditionSmall = UIFont(name: "Magic:the Gathering", size: 15.0)
        public static let eightEdition         = UIFont(name: "Matrix-Bold", size: 17.0)
        public static let eightEditionSmall    = UIFont(name: "Matrix-Bold", size: 15.0)
        public static let magic2015            = UIFont(name: "Beleren", size: 17.0)
        public static let magic2015Small       = UIFont(name: "Beleren", size: 15.0)
    }

    public enum PriceColors {
        public static let low    = UIColor.red
        public static let mid    = UIColor.blue
        public static let high   = UIColor(red:0.00, green:0.50, blue:0.00, alpha:1.0)
        public static let foil   = UIColor(red:0.60, green:0.51, blue:0.00, alpha:1.0)
        public static let normal = UIColor.black
    }
    
    public enum Constants {
        public static let ScryfallDateKey     = "ScryfallDateKey"
        public static let ScryfallDate        = "2018-12-11 09:21 UTC B"
        public static let KeyruneVersion      = "3.3.2"
        public static let EightEditionRelease = "2003-07-28"
        public static let TCGPlayerPricingAge = 24 * 3 // 3 days
    }
    
    public enum ImageName: String {
        case cardCircles       = "images/Card_Circles",
        cardBackCropped        = "images/cardback-crop-hq",
        cardBack               = "images/cardback-hq",
        collectorsCardBack     = "images/collectorscardback-hq",
        cropBack               = "images/cropback-hq",
        grayPatterned          = "images/Gray_Patterned_BG",
        intlCollectorsCardBack = "images/internationalcollectorscardback-hq"
    }
    
    public enum ImageType: Int {
        case png
        case borderCrop
        case artCrop
        case large
        case normal
        case small
        
        var description : String {
            switch self {
            
            case .png: return "png"
            case .borderCrop: return "border_crop"
            case .artCrop: return "art_crop"
            case .large: return "large"
            case .normal: return "normal"
            case .small: return "small"
            }
        }
    }
    
    public enum UserDefaultsKeys {
        public static let MTGJSONVersionKey   = "kMTGJSONVersionKey"
    }
    
    // MARK: - Shared Instance
    public static let sharedInstance = ManaKit()
    
    // MARK: Variables
    private var _dataStack: DataStack?
    public var dataStack: DataStack? {
        get {
            if _dataStack == nil {
                guard let bundleURL = Bundle(for: ManaKit.self).url(forResource: "ManaKit", withExtension: "bundle"),
                    let bundle = Bundle(url: bundleURL),
                    let momURL = bundle.url(forResource: "ManaKit", withExtension: "momd"),
                    let objectModel = NSManagedObjectModel(contentsOf: momURL) else {
                    return nil
                }
                _dataStack = DataStack(model: objectModel, storeType: .sqLite)
            }
            return _dataStack
        }
        set {
            _dataStack = newValue
        }
    }
    public let typeNames = ["Artifact",
                            "Chaos",
                            "Conspiracy",
                            "Creature",
                            "Enchantment",
                            "Instant",
                            "Land",
                            "Phenomenon",
                            "Plane",
                            "Planeswalker",
                            "Scheme",
                            "Sorcery",
                            "Tribal",
                            "Vanguard"]
    
    fileprivate var tcgPlayerPartnerKey: String?
    fileprivate var tcgPlayerPublicKey: String?
    fileprivate var tcgPlayerPrivateKey: String?
    
    // MARK: Resource methods
    public func nibFromBundle(_ name: String) -> UINib? {
        let bundle = Bundle(for: ManaKit.self)
        guard let bundleURL = bundle.resourceURL?.appendingPathComponent("ManaKit.bundle"),
            let resourceBundle = Bundle(url: bundleURL) else {
            return nil
        }
        
        return UINib(nibName: name, bundle: resourceBundle)
    }
    
    public func setupResources() {
        copyDatabaseFile()
        loadCustomFonts()
    }
    
    func copyDatabaseFile() {
        let bundle = Bundle(for: ManaKit.self)
        guard let bundleURL = bundle.resourceURL?.appendingPathComponent("ManaKit.bundle"),
            let resourceBundle = Bundle(url: bundleURL),
            let docsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
            let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first,
            let sourcePath = resourceBundle.path(forResource: "ManaKit.sqlite", ofType: "zip"),
            let bundleName = Bundle.main.infoDictionary?["CFBundleName"] as? String else {
            return
        }
        let targetPath = "\(docsPath)/\(bundleName).sqlite"
        var willCopy = true

        if let scryfallDate = UserDefaults.standard.string(forKey: Constants.ScryfallDateKey) {
            if scryfallDate == Constants.ScryfallDate {
                willCopy = false
            }
        }

        if willCopy {
            print("Copying database file: \(Constants.ScryfallDate)")

            // Shutdown database
            dataStack = nil
            
            // Remove old database files in docs directory
            for file in try! FileManager.default.contentsOfDirectory(atPath: docsPath) {
                let path = "\(docsPath)/\(file)"
                if file.hasPrefix(bundleName) {
                    try! FileManager.default.removeItem(atPath: path)
                }
            }
            
            // remove the contents of crop directory
            let cropPath = "\(cachePath)/crop/"
            if FileManager.default.fileExists(atPath: cropPath) {
                for file in try! FileManager.default.contentsOfDirectory(atPath: cropPath) {
                    let path = "\(cropPath)/\(file)"
                    try! FileManager.default.removeItem(atPath: path)
                }
            }

            // delete image cache
            let imageCache = SDImageCache.init()
            imageCache.clearDisk(onCompletion: nil)
            
            // Unzip
            SSZipArchive.unzipFile(atPath: sourcePath, toDestination: docsPath)
            
            // rename
            try! FileManager.default.moveItem(atPath: "\(docsPath)/ManaKit.sqlite", toPath: targetPath)
            
            // skip from iCloud backups!
            var targetURL = URL(fileURLWithPath: targetPath)
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try! targetURL.setResourceValues(resourceValues)
            
            UserDefaults.standard.set(Constants.ScryfallDate, forKey: Constants.ScryfallDateKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    func loadCustomFonts() {
        let bundle = Bundle(for: ManaKit.self)
        guard let bundleURL = bundle.resourceURL?.appendingPathComponent("ManaKit.bundle"),
            let resourceBundle = Bundle(url: bundleURL),
            let urls = resourceBundle.urls(forResourcesWithExtension: "ttf", subdirectory: "fonts") else {
            return
        }
        
        for url in urls {
            let data = try! Data(contentsOf: url)
            let error: UnsafeMutablePointer<Unmanaged<CFError>?>? = nil

            if let provider = CGDataProvider(data: data as CFData),
                let font = CGFont(provider) {
                
                if !CTFontManagerRegisterGraphicsFont(font, error) {
                    if let unmanagedError = error?.pointee {
                        if let errorDescription = CFErrorCopyDescription(unmanagedError.takeUnretainedValue()) {
                            print("Failed to load font: \(errorDescription)")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Database methods
    public func findObject(_ entityName: String,
                           objectFinder: [String: AnyObject]?,
                           createIfNotFound: Bool) -> NSManagedObject? {
        let context = dataStack!.mainContext
        
        var object:NSManagedObject?
        var predicate:NSPredicate?
        var fetchRequest:NSFetchRequest<NSFetchRequestResult>?
        
        if let objectFinder = objectFinder {
            for (key,value) in objectFinder {
                if predicate != nil {
                    predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate!, NSPredicate(format: "%K == [c] %@", key, value as! NSObject)])
                } else {
                    predicate = NSPredicate(format: "%K == [c] %@", key, value as! NSObject)
                }
            }

            fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            fetchRequest!.predicate = predicate
        }
        
        if let fetchRequest = fetchRequest {
            if let m = try! context.fetch(fetchRequest).first as? NSManagedObject {
                object = m
            } else {
                if createIfNotFound {
                    if let desc = NSEntityDescription.entity(forEntityName: entityName, in: context) {
                        object = NSManagedObject(entity: desc, insertInto: context)
                    }
                }
            }
        } else {
            if createIfNotFound {
                if let desc = NSEntityDescription.entity(forEntityName: entityName, in: context) {
                    object = NSManagedObject(entity: desc, insertInto: context)
                }
            }
        }
        
        return object
    }
    
    public func saveContext() {
        guard let dataStack = dataStack else {
            return
        }
        
        if dataStack.mainContext.hasChanges {
            do {
                try dataStack.mainContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    public func typeImage(ofCard card: CMCard) -> UIImage? {
        if let type = card.myType,
            let name = type.name {

            return ManaKit.sharedInstance.symbolImage(name: name)
        }
        
        return nil
    }
    
    public func typeText(ofCard card: CMCard, includePower: Bool) -> String {
        var typeText = ""
        
        if let language = card.language,
            let code = language.code {
            
            if code == "en" {
                if let type = card.typeLine,
                    let name = type.name {
                    typeText = name
                }
            } else {
                if let type = card.printedTypeLine,
                    let name = type.name {
                    typeText = name
                }
            }
            
            // fallback to default typeLine
            if typeText.count == 0 {
                if let type = card.typeLine,
                    let name = type.name {
                    typeText = name
                }
            }
            
            if includePower {
                if let power = card.power,
                    let toughness = card.toughness {
                    typeText.append(" (\(power)/\(toughness))")
                }
                
                if let loyalty = card.loyalty {
                    typeText.append(" (\(loyalty))")
                }
            }
        }
        
        return typeText
    }
    
    public func imageURL(ofCard card: CMCard, imageType: ImageType, faceOrder: Int) -> URL? {
        var url:URL?
        var urlString: String?
        
        
        if let imageURIs = card.imageURIs,
            let dict = NSKeyedUnarchiver.unarchiveObject(with: imageURIs as Data) as? [String: String] {
            urlString = dict[imageType.description]
        } else {
            if let facesSet = card.faces,
                let faces = facesSet.allObjects as? [CMCard] {
                let orderedFaces = faces.sorted(by: {(a, b) -> Bool in
                    return a.faceOrder < b.faceOrder
                })
                let face = orderedFaces[faceOrder]
                
                if let imageURIs = face.imageURIs,
                    let dict = NSKeyedUnarchiver.unarchiveObject(with: imageURIs as Data) as? [String: String] {
                    urlString = dict[imageType.description]
                }
            }
        }
        
        if let urlString = urlString {
            url = URL(string: urlString)
        }
        
        return url
    }
    
    public func isModern(_ card: CMCard) -> Bool {
        guard let releaseDate = card.set!.releaseDate else {
            return false
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let eightEditionDate = formatter.date(from: Constants.EightEditionRelease),
            let setReleaseDate = formatter.date(from: releaseDate) {
            return setReleaseDate.compare(eightEditionDate) == .orderedDescending ||
                setReleaseDate.compare(eightEditionDate) == .orderedSame
        }
        
        return false
    }
    

    // MARK: Image methods
    public func imageFromFramework(imageName: ImageName) -> UIImage? {
        let bundle = Bundle(for: ManaKit.self)
        guard let bundleURL = bundle.resourceURL?.appendingPathComponent("ManaKit.bundle"),
            let resourceBundle = Bundle(url: bundleURL) else {
                return nil
        }
        
        return UIImage(named: imageName.rawValue, in: resourceBundle, compatibleWith: nil)
    }
    
    public func symbolImage(name: String) -> UIImage? {
        let bundle = Bundle(for: ManaKit.self)
        guard let bundleURL = bundle.resourceURL?.appendingPathComponent("ManaKit.bundle"),
            let resourceBundle = Bundle(url: bundleURL) else {
                return nil
        }
        
        return UIImage(named: name, in: resourceBundle, compatibleWith: nil)
    }
    
    public func downloadImage(ofCard card: CMCard, imageType: ImageType, faceOrder: Int) -> Promise<Void> {
        return Promise { seal  in
            guard let url = imageURL(ofCard: card,
                                     imageType: imageType,
                                     faceOrder: faceOrder) else {
                let error = NSError(domain: NSURLErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey: "No valid URL for image"])
                seal.reject(error)
                return
            }
            let roundCornered = imageType != .artCrop
            
            if let _ = self.cardImage(card,
                                      imageType: imageType,
                                      faceOrder: faceOrder,
                                      roundCornered: roundCornered) {
                seal.fulfill(())
            } else {
                let downloader = SDWebImageDownloader.shared()
                let cacheKey = url.absoluteString
                let completion = { (image: UIImage?, data: Data?, error: Error?, finished: Bool) in
                    if let error = error {
                        seal.reject(error)
                    } else {
                        if let image = image {
                            let imageCache = SDImageCache.init()
                            imageCache.store(image,
                                             forKey: cacheKey,
                                             toDisk: true,
                                             completion: {
                                                seal.fulfill(())
                            })
                            
                        } else {
                            let error = NSError(domain: NSURLErrorDomain,
                                                code: 404,
                                                userInfo: [NSLocalizedDescriptionKey: "Image not found: \(url)"])
                            seal.reject(error)
                        }
                    }
                }
                
                downloader.downloadImage(with: url, options: .lowPriority, progress: nil, completed: completion)
            }
        }
    }
    
    public func cardImage(_ card: CMCard, imageType: ImageType, faceOrder: Int, roundCornered: Bool) -> UIImage? {
        var cardImage: UIImage?
        
        guard let url = imageURL(ofCard: card,
                                 imageType: imageType,
                                 faceOrder: faceOrder) else {
            return nil
        }
        
        let imageCache = SDImageCache.init()
        let cacheKey = url.absoluteString
        
        cardImage = imageCache.imageFromDiskCache(forKey: cacheKey)
        
        if roundCornered {
            if let c = cardImage {
                cardImage = c.roundCornered(card: card)
            }
        }
        
        return cardImage
    }
    
    public func cardBack(_ card: CMCard) -> UIImage? {
        if card.set!.code == "ced" {
            return imageFromFramework(imageName: .collectorsCardBack)
        } else if card.set!.code == "cei" {
            return imageFromFramework(imageName: .intlCollectorsCardBack)
        } else {
            return imageFromFramework(imageName: .cardBack)
        }
    }
    
    // MARK: TCGPlayer
    public func configureTCGPlayer(partnerKey: String, publicKey: String?, privateKey: String?) {
        tcgPlayerPartnerKey = partnerKey
        tcgPlayerPublicKey = publicKey
        tcgPlayerPrivateKey = privateKey
    }
    
    public func fetchTCGPlayerCardPricing(card: CMCard) -> Promise<Void> {
        return Promise { seal  in
            var pricing = card.pricing
            var willFetch = false

            if pricing != nil {
                if let lastUpdate = pricing!.lastUpdate {
                    if let diff = Calendar.current.dateComponents([.hour], from: lastUpdate as Date, to: Date()).hour, diff >= Constants.TCGPlayerPricingAge {
                        willFetch = true
                    }
                } else {
                    willFetch = true
                }
            } else {
                guard let desc = NSEntityDescription.entity(forEntityName: "CMCardPricing", in: dataStack!.mainContext),
                    let p = NSManagedObject(entity: desc, insertInto: dataStack!.mainContext) as? CMCardPricing else {
                    fatalError()
                }
                try! dataStack!.mainContext.save()
                pricing = p
                willFetch = true
            }
            
            if willFetch {
                guard let tcgPlayerPartnerKey = tcgPlayerPartnerKey,
                    let set = card.set,
                    let tcgPlayerSetName = set.tcgplayerName,
                    let cardName = card.name,
                    let urlString = "http://partner.tcgplayer.com/x3/phl.asmx/p?pk=\(tcgPlayerPartnerKey)&s=\(tcgPlayerSetName)&p=\(cardName)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                    let url = URL(string: urlString) else {
                    
                    seal.fulfill(())
                    return
                }
                
                var rq = URLRequest(url: url)
                rq.httpMethod = "GET"
                
                firstly {
                    URLSession.shared.dataTask(.promise, with: rq)
                }.map {
                    try! XML(xml: $0.data, encoding: .utf8)
                }.done { xml in
                    for product in xml.xpath("//product") {
                        if let id = product.xpath("id").first?.text,
                            let hiprice = product.xpath("hiprice").first?.text,
                            let lowprice = product.xpath("lowprice").first?.text,
                            let avgprice = product.xpath("avgprice").first?.text,
                            let foilavgprice = product.xpath("foilavgprice").first?.text,
                            let link = product.xpath("link").first?.text {
                            pricing!.id = Int64(id)!
                            pricing!.high = Double(hiprice)!
                            pricing!.low = Double(lowprice)!
                            pricing!.average = Double(avgprice)!
                            pricing!.foil = Double(foilavgprice)!
                            pricing!.link = link
                        }
                    }
                    pricing!.lastUpdate = NSDate()
                    card.pricing = pricing
                    
                    self.dataStack!.performInNewBackgroundContext { backgroundContext in
                        try! backgroundContext.save()
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
    
    public func fetchTCGPlayerStorePricing(card: CMCard) -> Promise<Void> {
        return Promise { seal  in
            var willFetch = true
            
            if let storePricing = card.tcgplayerStorePricing {
                if let lastUpdate = storePricing.lastUpdate {
                    if let diff = Calendar.current.dateComponents([.hour], from: lastUpdate as Date, to: Date()).hour {
                        if diff <= Constants.TCGPlayerPricingAge {
                            willFetch = false
                        }
                    }
                }
            }
            
            if willFetch {
                guard let tcgPlayerPartnerKey = tcgPlayerPartnerKey,
                    let set = card.set,
                    let tcgPlayerSetName = set.tcgplayerName,
                    let cardName = card.name,
                    let urlString = "http://partner.tcgplayer.com/x3/pv.asmx/p?pk=\(tcgPlayerPartnerKey)&s=\(tcgPlayerSetName)&p=\(cardName)&v=8".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                    let url = URL(string: urlString) else {
                    
                    seal.fulfill(())
                    return
                }

                // cleanup existing storePricing, if there is any
                var storePricing: CMStorePricing?
                if let sp = card.tcgplayerStorePricing {
                    let suppliers = sp.mutableSetValue(forKey: "suppliers")
                    for supplier in suppliers {
                        suppliers.remove(supplier)
                    }
                    sp.notes = nil
                    sp.lastUpdate = nil
                    storePricing = sp
                } else {
                    if let desc = NSEntityDescription.entity(forEntityName: "CMStorePricing", in: dataStack!.mainContext),
                        let sp = NSManagedObject(entity: desc, insertInto: dataStack!.mainContext) as? CMStorePricing {
                        
                        sp.addToCards(card)
                        storePricing = sp
                    }
                }
                try! dataStack!.mainContext.save()
                
                var rq = URLRequest(url: url)
                rq.httpMethod = "GET"
            
                firstly {
                    URLSession.shared.dataTask(.promise, with: rq)
                }.map {
                    try! XML(xml: $0.data, encoding: .utf8)
                }.done { xml in
                    for supplier in xml.xpath("//supplier") {
                        if let name = supplier.xpath("name").first?.text,
                            let condition = supplier.xpath("condition").first?.text,
                            let qty = supplier.xpath("qty").first?.text,
                            let price = supplier.xpath("price").first?.text,
                            let link = supplier.xpath("link").first?.text {
                            
                            let id = "\(name)_\(condition)_\(qty)_\(price)"
                            if let sup = self.findObject("CMStoreSupplier",
                                                         objectFinder: ["id": id as AnyObject],
                                                         createIfNotFound: true) as? CMStoreSupplier {
                            
                                sup.id = id
                                sup.name = name
                                sup.condition = condition
                                sup.qty = Int32(qty)!
                                sup.price = Double(price)!
                                sup.link = link
                                storePricing!.addToSuppliers(sup)
                            }
                        }
                    }
                    if let note = xml.xpath("//note").first?.text {
                        storePricing!.notes = note
                    }
                    storePricing!.lastUpdate = NSDate()
                    
                    self.dataStack!.performInNewBackgroundContext { backgroundContext in
                        try! backgroundContext.save()
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
    
    // MARK: Keyrune
    public func keyruneUnicode(forSet set: CMSet) -> String? {
        var unicode:String?
        
        if let keyruneCode = set.myKeyruneCode {
            let charAsInt = Int(keyruneCode, radix: 16)!
            let uScalar = UnicodeScalar(charAsInt)!
            unicode = "\(uScalar)"
        } else {
            let charAsInt = Int("e684", radix: 16)!
            let uScalar = UnicodeScalar(charAsInt)!
            unicode = "\(uScalar)"
        }
        
        return unicode
    }
        
    public func keyruneColor(forCard card: CMCard) -> UIColor? {
        guard let set = card.set,
            let rarity = card.rarity else {
            return nil
        }
        
        var color:UIColor?
        
        if set.code == "tsb" {
            color = UIColor(hex: "652978") // purple
        } else {
            if rarity.name == "Common" {
                color = UIColor(hex: "1A1718")
            } else if rarity.name == "Uncommon" {
                color = UIColor(hex: "707883")
            } else if rarity.name == "Rare" {
                color = UIColor(hex: "A58E4A")
            } else if rarity.name == "Mythic" {
                color = UIColor(hex: "BF4427")
            } else if rarity.name == "Special" {
                color = UIColor(hex: "BF4427")
            } else if rarity.name == "Timeshifted" {
                color = UIColor(hex: "652978")
            } else if rarity.name == "Basic Land" {
                color = UIColor(hex: "000000")
            }
        }
        
        return color
    }
}
