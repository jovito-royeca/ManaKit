//
//  CMSet.swift
//  Pods
//
//  Created by Jovito Royeca on 26/12/2018.
//
//

import Foundation
import RealmSwift


public class CMSet: Object {

    @objc public dynamic var cardCount = Int32(0)
    @objc public dynamic var code: String? = nil
    @objc public dynamic var isFoilOnly = false
    @objc public dynamic var isOnlineOnly = false
    @objc public dynamic var mtgoCode: String? = nil
    @objc public dynamic var myKeyruneCode: String? = nil
    @objc public dynamic var myNameSection: String? = nil
    @objc public dynamic var myYearSection: String? = nil
    @objc public dynamic var name: String? = nil
    @objc public dynamic var releaseDate: String? = nil
    @objc public dynamic var tcgPlayerID = Int32(0)

    // MARK: Relationships
    @objc public dynamic var block: CMSetBlock?
    public let cards = List<CMCard>()
    public let children = List<CMSet>()
    public let languages = LinkingObjects(fromType: CMLanguage.self, property: "sets")
    @objc public dynamic var parent: CMSet?
    @objc public dynamic var setType: CMSetType?

    // MARK: Primary key
    override public static func primaryKey() -> String? {
        return "code"
    }

    // MARK: Custom methods
    public func keyruneUnicode() -> String? {
        var unicode:String?
        
        if let keyruneCode = myKeyruneCode {
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
}

