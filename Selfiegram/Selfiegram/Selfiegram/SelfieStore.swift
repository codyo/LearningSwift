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
        //figure out where the file would end up
        let fileName = "\(id.uuidString)-image.jpg"
        let destinationURL = self.documentsFolder.appendingPathComponent(fileName)
        
        if let image = image {
            //we have an image to owrk with, so save it out.
            //Attempt to convert the image into JPEG data.
            guard let data = UIImageJPEGRepresentation(image, 0.9)
            else {
                    //throw an error if this failed
                    throw SelfieStoreError.cannotSaveImage(image)
            }
            //Attempt to write the data out
            try data.write(to:destinationURL)
        } else {
            //The image is nil, indicating that we want to remove the image.
            //Attempt to perform the deletion.
            try FileManager.default.removeItem(at: destinationURL)
        }
        
        //Cache this image in memory.
        //(If image is nil, this has the effect of removing the entry from the cache dictionary.)
        imageCache[id] = image
        
        
        
    }
    
    ///returns a list of selfie objects loaded from disk.
    /// - returns: an array of all selfies previously saved
    /// - Throws: 'SelfieStoreError' if it fails to load a selfie correctly from disk
    func listSelfies() throws -> [Selfie] {
        //Get the list of files in the Documents directory
        let contents = try FileManager.default.contentsOfDirectory(at:self.documentsFolder, includingPropertiesForKeys:nil)
        
        //Get all files whos path extension is 'json',
        //load them as data, and deconde them from JSON
        return try contents.filter { $0.pathExtension == "json"}
            .map{try Data(contentsOf: $0) }
            .map{try JSONDecoder().decode(Selfie.self, from: $0) }
    }
    
    ///deletes a selfie (and it's corresponding image) from disk
    ///this function simply takes the ID from the Selfie you pass in,
    ///and gives it to the other version of the delete function
    /// - parameter selfie: the selfie you want deleted
    /// - Throws: 'SelfieStoreError' if it fails to delete the selfie from disk
    func delete(selfie:Selfie) throws {
        try delete(id: selfie.id)
    }
    
    ///deletes a selfie (and it's corresponding image) from disk
    /// - parameter id: the id property of the Selfie you want deleted
    /// - Throws: 'SelfieStoreError' if it fails to delete the selfie from disk
    func delete(id:UUID) throws {
        let selfieDataFileName = "\(id.uuidString).json"
        let imageFileName = "\(id.uuidString)-image.jpg"
        
        let selfieDataURL = self.documentsFolder.appendingPathComponent(selfieDataFileName)
        let imageURL = self.documentsFolder.appendingPathComponent(imageFileName)
        
        //remove the two files if they exist
        if FileManager.default.fileExists(atPath: selfieDataURL.path){
            try FileManager.default.removeItem(at: selfieDataURL)
        }
        
        if FileManager.default.fileExists(atPath: imageURL.path) {
            try FileManager.default.removeItem(at: imageURL)
        }
        
        //Wipe the image from the cache if it's there
        imageCache[id] = nil
    }
    
    ///attempts to load a selfie from disk
    /// - parameter id: the id property of the Selfie object you want loaded from disk
    /// - returns: the selfie with the matching id, or nil if it doesn't exist
    func load(id:UUID) -> Selfie? {
        let dataFileName = "\(id.uuidString).json"
        let dataURL = self.documentsFolder.appendingPathComponent(dataFileName)
        
        //attemmpts to load the data in the file,
        //and then attempt to convert the data into a photo, and then return it.
        //return nil if any of these fail
        if let data = try? Data(contentsOf: dataURL),
            let selfie = try? JSONDecoder().decode(Selfie.self, from: data) {
            return selfie
        } else {
            return nil
        }
        
    }
    
    ///attempts to save a selfie to disk.
    /// - parameter selfie: the selfie you want to save to disk
    /// - Throws: 'SelfieStoreError' if it fails to write the data to disk
    func save(selfie:Selfie) throws {
        let selfieData = try JSONEncoder().encode(selfie)
        
        let fileName = "\(selfie.id.uuidString).json"
        let destinationURL = self.documentsFolder.appendingPathComponent(fileName)
        
        try selfieData.write(to: destinationURL)
    }
    
    
}










