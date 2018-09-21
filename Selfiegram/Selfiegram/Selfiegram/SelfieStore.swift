//
//  SelfieStore.swift
//  Selfiegram
//
//  Created by Cody on 9/21/18.
//  Copyright © 2018 HoorayArray. All rights reserved.
//

import Foundation
import UIKit.UIImage

class Selfie:Codable {
    //when it was created
    let created:Date
    
    //a unique ID, used to link this selfie to its image on disk
    let id:UUID
    
    //the name of this selfie
    var title = "New Selfie!"
    
    //the image on disk for this selfie
    var image:UIImage? {
        get {
            return SelfieStore.shared.getImage(id:self.id)
        }
        set {
            try? SelfieStore.shared.setImage(id:self.id, image:newValue)
        }
    }
    
    init(title:String){
        self.title = title
        // the current time
        self.created = Date()
        //a new UUID
        self.id = UUID()
    }
}

enum SelfieStoreError:Error {
    case cannotSaveImage(UIImage?)
}

final class SelfieStore {
    static let shared = SelfieStore()
    private var imageCache: [UUID:UIImage] = [:]
    var documentsFolder:URL {
        return FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first!
    }
    
    ///Gets an image by ID.
    ///Will be cached in memory for future lookups.
    /// - parameter id: the id of the selfie who's image you are after
    /// - returns: the image for the selfie or nil if it doesn't exist
    func getImage(id:UUID) -> UIImage? {
        //if this image is already in the cache, return it
        if let image = imageCache[id] {
            return image
        }
        
        //figure out where this image should live
        let imageURL = documentsFolder.appendingPathComponent("\(id.uuidString)-image.jpg")
        
        guard let imageData = try? Data(contentsOf: imageURL) else {
                return nil
        }
        
        guard let image = UIImage(data:imageData) else {
            return nil
        }
        
        //store the loaded image in the cache for next time
        imageCache[id] = image
        
        //return the loaded image
        return image
        
    }
    
    ///saves an image to disk
    /// - parameter id: the id of the selfie you want this image associated with
    /// - parameter image: the image you want saved
    /// - Throws: 'SelfieStoreObject' if it fails to save to disk
    func setImage(id:UUID, image:UIImage?) throws {
        throw SelfieStoreError.cannotSaveImage(image)
    }
    
    ///returns a list of selfie objects loaded from disk.
    /// - returns: an array of all selfies previously saved
    /// - Throws: 'SelfieStoreError' if it fails to load a selfie correctly from disk
    func listSelfies() throws -> [Selfie] {
        return []
    }
    
    ///deletes a selfie (and it's corresponding image) from disk
    ///this function simply takes the ID from the Selfie you pass in,
    ///and gives it to the other version of the delete function
    /// - parameter selfie: the selfie you want deleted
    /// - Throws: 'SelfieStoreError' if it fails to delete the selfie from disk
    func delete(selfie:Selfie) throws {
        throw SelfieStoreError.cannotSaveImage(nil)
    }
    
    ///deletes a selfie (and it's corresponding image) from disk
    /// - parameter id: the id property of the Selfie you want deleted
    /// - Throws: 'SelfieStoreError' if it fails to delete the selfie from disk
    func delete(id:UUID) throws {
        throw SelfieStoreError.cannotSaveImage(nil)
    }
    
    ///attempts to load a selfie from disk
    /// - parameter id: the id property of the Selfie object you want loaded from disk
    /// - returns: the selfie with the matching id, or nil if it doesn't exist
    func load(id:UUID) -> Selfie? {
        return nil
    }
    
    ///attempts to save a selfie to disk.
    /// - parameter selfie: the selfie you want to save to disk
    /// - Throws: 'SelfieStoreError' if it fails to write the data to disk
    func save(selfie:Selfie) throws {
        throw SelfieStoreError.cannotSaveImage(nil)
    }
    
    
}










