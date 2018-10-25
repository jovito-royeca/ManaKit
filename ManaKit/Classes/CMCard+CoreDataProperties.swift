//
//  CMCard+CoreDataProperties.swift
//  Pods
//
//  Created by Jovito Royeca on 23/10/2018.
//
//

import Foundation
import CoreData


extension CMCard {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CMCard> {
        return NSFetchRequest<CMCard>(entityName: "CMCard")
    }

    @NSManaged public var arenaId: String?
    @NSManaged public var collectorNumber: String?
    @NSManaged public var comvertedManaCost: Double
    @NSManaged public var firebaseId: String?
    @NSManaged public var flavorText: String?
    @NSManaged public var id: String?
    @NSManaged public var imageUris: NSData?
    @NSManaged public var isFoil: Bool
    @NSManaged public var isFullArt: Bool
    @NSManaged public var isNonFoil: Bool
    @NSManaged public var isOversized: Bool
    @NSManaged public var isReprint: Bool
    @NSManaged public var isReserved: Bool
    @NSManaged public var isTimeshifted: Bool
    @NSManaged public var loyalty: String?
    @NSManaged public var manaCost: String?
    @NSManaged public var mtgjsonOriginalText: String?
    @NSManaged public var mtgoFoilId: String?
    @NSManaged public var mtgoId: String?
    @NSManaged public var multiverseIds: NSData?
    @NSManaged public var name: String?
    @NSManaged public var myNameSection: String?
    @NSManaged public var myNumberOrder: Double
    @NSManaged public var oracleId: String?
    @NSManaged public var oracleText: String?
    @NSManaged public var power: String?
    @NSManaged public var firebaseRating: Double
    @NSManaged public var firebaseRatings: Int32
    @NSManaged public var releaseDate: String?
    @NSManaged public var source: String?
    @NSManaged public var toughness: String?
    @NSManaged public var firebaseViews: Int64
    @NSManaged public var isColorshifted: Bool
    @NSManaged public var isDigital: Bool
    @NSManaged public var printedName: String?
    @NSManaged public var printedText: String?
    @NSManaged public var isFutureshifted: Bool
    @NSManaged public var isHighResImage: Bool
    @NSManaged public var illustrationId: String?
    @NSManaged public var isStorySpotlight: Bool
    @NSManaged public var artist: CMArtist?
    @NSManaged public var borderColor: CMCardBorderColor?
    @NSManaged public var cardLegalities: NSSet?
    @NSManaged public var colorIdentities: NSSet?
    @NSManaged public var colorIndicators: NSSet?
    @NSManaged public var colors: NSSet?
    @NSManaged public var deckHeroes: NSSet?
    @NSManaged public var face: CMCard?
    @NSManaged public var faces: NSSet?
    @NSManaged public var frame: CMCardFrame?
    @NSManaged public var imageURIs: NSSet?
    @NSManaged public var inventories: NSSet?
    @NSManaged public var language: CMLanguage?
    @NSManaged public var layout: CMCardLayout?
    @NSManaged public var mtgjsonOriginalType: CMCardType?
    @NSManaged public var part: CMCard?
    @NSManaged public var parts: NSSet?
    @NSManaged public var pricing: CMCardPricing?
    @NSManaged public var printings: NSSet?
    @NSManaged public var rarity: CMRarity?
    @NSManaged public var rulings: NSSet?
    @NSManaged public var set: CMSet?
    @NSManaged public var tcgplayerStorePricing: CMStorePricing?
    @NSManaged public var variations: NSSet?
    @NSManaged public var otherPrintings: NSSet?
    @NSManaged public var mtgjsonSubtypes: NSSet?
    @NSManaged public var mtgjsonSupertypes: NSSet?
    @NSManaged public var typeLine: CMCardType?
    @NSManaged public var mtgjsonTypes: NSSet?
    @NSManaged public var firebaseUserFavorites: NSSet?
    @NSManaged public var firebaseUserRatings: NSSet?
    @NSManaged public var printedTypeLine: CMCardType?
    @NSManaged public var watermark: CMCardWatermark?

}

// MARK: Generated accessors for cardLegalities
extension CMCard {

    @objc(addCardLegalitiesObject:)
    @NSManaged public func addToCardLegalities(_ value: CMCardLegality)

    @objc(removeCardLegalitiesObject:)
    @NSManaged public func removeFromCardLegalities(_ value: CMCardLegality)

    @objc(addCardLegalities:)
    @NSManaged public func addToCardLegalities(_ values: NSSet)

    @objc(removeCardLegalities:)
    @NSManaged public func removeFromCardLegalities(_ values: NSSet)

}

// MARK: Generated accessors for colorIdentities
extension CMCard {

    @objc(addColorIdentitiesObject:)
    @NSManaged public func addToColorIdentities(_ value: CMCardColor)

    @objc(removeColorIdentitiesObject:)
    @NSManaged public func removeFromColorIdentities(_ value: CMCardColor)

    @objc(addColorIdentities:)
    @NSManaged public func addToColorIdentities(_ values: NSSet)

    @objc(removeColorIdentities:)
    @NSManaged public func removeFromColorIdentities(_ values: NSSet)

}

// MARK: Generated accessors for colorIndicators
extension CMCard {

    @objc(addColorIndicatorsObject:)
    @NSManaged public func addToColorIndicators(_ value: CMCardColor)

    @objc(removeColorIndicatorsObject:)
    @NSManaged public func removeFromColorIndicators(_ value: CMCardColor)

    @objc(addColorIndicators:)
    @NSManaged public func addToColorIndicators(_ values: NSSet)

    @objc(removeColorIndicators:)
    @NSManaged public func removeFromColorIndicators(_ values: NSSet)

}

// MARK: Generated accessors for colors
extension CMCard {

    @objc(addColorsObject:)
    @NSManaged public func addToColors(_ value: CMCardColor)

    @objc(removeColorsObject:)
    @NSManaged public func removeFromColors(_ value: CMCardColor)

    @objc(addColors:)
    @NSManaged public func addToColors(_ values: NSSet)

    @objc(removeColors:)
    @NSManaged public func removeFromColors(_ values: NSSet)

}

// MARK: Generated accessors for deckHeroes
extension CMCard {

    @objc(addDeckHeroesObject:)
    @NSManaged public func addToDeckHeroes(_ value: CMDeck)

    @objc(removeDeckHeroesObject:)
    @NSManaged public func removeFromDeckHeroes(_ value: CMDeck)

    @objc(addDeckHeroes:)
    @NSManaged public func addToDeckHeroes(_ values: NSSet)

    @objc(removeDeckHeroes:)
    @NSManaged public func removeFromDeckHeroes(_ values: NSSet)

}

// MARK: Generated accessors for faces
extension CMCard {

    @objc(addFacesObject:)
    @NSManaged public func addToFaces(_ value: CMCard)

    @objc(removeFacesObject:)
    @NSManaged public func removeFromFaces(_ value: CMCard)

    @objc(addFaces:)
    @NSManaged public func addToFaces(_ values: NSSet)

    @objc(removeFaces:)
    @NSManaged public func removeFromFaces(_ values: NSSet)

}

// MARK: Generated accessors for inventories
extension CMCard {

    @objc(addInventoriesObject:)
    @NSManaged public func addToInventories(_ value: CMCardInventory)

    @objc(removeInventoriesObject:)
    @NSManaged public func removeFromInventories(_ value: CMCardInventory)

    @objc(addInventories:)
    @NSManaged public func addToInventories(_ values: NSSet)

    @objc(removeInventories:)
    @NSManaged public func removeFromInventories(_ values: NSSet)

}

// MARK: Generated accessors for parts
extension CMCard {

    @objc(addPartsObject:)
    @NSManaged public func addToParts(_ value: CMCard)

    @objc(removePartsObject:)
    @NSManaged public func removeFromParts(_ value: CMCard)

    @objc(addParts:)
    @NSManaged public func addToParts(_ values: NSSet)

    @objc(removeParts:)
    @NSManaged public func removeFromParts(_ values: NSSet)

}

// MARK: Generated accessors for printings
extension CMCard {

    @objc(addPrintingsObject:)
    @NSManaged public func addToPrintings(_ value: CMSet)

    @objc(removePrintingsObject:)
    @NSManaged public func removeFromPrintings(_ value: CMSet)

    @objc(addPrintings:)
    @NSManaged public func addToPrintings(_ values: NSSet)

    @objc(removePrintings:)
    @NSManaged public func removeFromPrintings(_ values: NSSet)

}

// MARK: Generated accessors for rulings
extension CMCard {

    @objc(addRulingsObject:)
    @NSManaged public func addToRulings(_ value: CMRuling)

    @objc(removeRulingsObject:)
    @NSManaged public func removeFromRulings(_ value: CMRuling)

    @objc(addRulings:)
    @NSManaged public func addToRulings(_ values: NSSet)

    @objc(removeRulings:)
    @NSManaged public func removeFromRulings(_ values: NSSet)

}

// MARK: Generated accessors for mtgjsonSubtypes
extension CMCard {

    @objc(addMtgjsonSubtypesObject:)
    @NSManaged public func addToMtgjsonSubtypes(_ value: CMCardType)

    @objc(removeMtgjsonSubtypesObject:)
    @NSManaged public func removeFromMtgjsonSubtypes(_ value: CMCardType)

    @objc(addMtgjsonSubtypes:)
    @NSManaged public func addToMtgjsonSubtypes(_ values: NSSet)

    @objc(removeMtgjsonSubtypes:)
    @NSManaged public func removeFromMtgjsonSubtypes(_ values: NSSet)

}

// MARK: Generated accessors for mtgjsonSupertypes
extension CMCard {

    @objc(addMtgjsonSupertypesObject:)
    @NSManaged public func addToMtgjsonSupertypes(_ value: CMCardType)

    @objc(removeMtgjsonSupertypesObject:)
    @NSManaged public func removeFromMtgjsonSupertypes(_ value: CMCardType)

    @objc(addMtgjsonSupertypes:)
    @NSManaged public func addToMtgjsonSupertypes(_ values: NSSet)

    @objc(removeMtgjsonSupertypes:)
    @NSManaged public func removeFromMtgjsonSupertypes(_ values: NSSet)

}

// MARK: Generated accessors for mtgjsonTypes
extension CMCard {

    @objc(addMtgjsonTypesObject:)
    @NSManaged public func addToMtgjsonTypes(_ value: CMCardType)

    @objc(removeMtgjsonTypesObject:)
    @NSManaged public func removeFromMtgjsonTypes(_ value: CMCardType)

    @objc(addMtgjsonTypes:)
    @NSManaged public func addToMtgjsonTypes(_ values: NSSet)

    @objc(removeMtgjsonTypes:)
    @NSManaged public func removeFromMtgjsonTypes(_ values: NSSet)

}

// MARK: Generated accessors for firebaseUserFavorites
extension CMCard {

    @objc(addFirebaseUserFavoritesObject:)
    @NSManaged public func addToFirebaseUserFavorites(_ value: CMUser)

    @objc(removeFirebaseUserFavoritesObject:)
    @NSManaged public func removeFromFirebaseUserFavorites(_ value: CMUser)

    @objc(addFirebaseUserFavorites:)
    @NSManaged public func addToFirebaseUserFavorites(_ values: NSSet)

    @objc(removeFirebaseUserFavorites:)
    @NSManaged public func removeFromFirebaseUserFavorites(_ values: NSSet)

}

// MARK: Generated accessors for firebaseUserRatings
extension CMCard {

    @objc(addFirebaseUserRatingsObject:)
    @NSManaged public func addToFirebaseUserRatings(_ value: CMCardRating)

    @objc(removeFirebaseUserRatingsObject:)
    @NSManaged public func removeFromFirebaseUserRatings(_ value: CMCardRating)

    @objc(addFirebaseUserRatings:)
    @NSManaged public func addToFirebaseUserRatings(_ values: NSSet)

    @objc(removeFirebaseUserRatings:)
    @NSManaged public func removeFromFirebaseUserRatings(_ values: NSSet)

}

// MARK: Generated accessors for variations
extension CMCard {
    
    @objc(addVariationsObject:)
    @NSManaged public func addToVariations(_ value: CMCard)
    
    @objc(removeVariationsObject:)
    @NSManaged public func removeFromVariations(_ value: CMCard)
    
    @objc(addVariations:)
    @NSManaged public func addToVariations(_ values: NSSet)
    
    @objc(removeVariations:)
    @NSManaged public func removeFromVariations(_ values: NSSet)
    
}

// MARK: Generated accessors for other printings
extension CMCard {
    
    @objc(addOtherPrintingsObject:)
    @NSManaged public func addToOtherPrintings(_ value: CMCard)
    
    @objc(removeOtherPrintingsObject:)
    @NSManaged public func removeFromOtherPrintings(_ value: CMCard)
    
    @objc(addOtherPrintings:)
    @NSManaged public func addToOtherPrintings(_ values: NSSet)
    
    @objc(removeOtherPrintings:)
    @NSManaged public func removeFromOtherPrintings(_ values: NSSet)
    
}
