//
//  WeatherPic.swift
//  Photo Bucket Core Data
//
//  Created by CSSE Department on 4/22/18.
//  Copyright © 2018 Rose-Hulman. All rights reserved.
//

import Foundation
import Firebase
import UIKit

class WeatherPic: NSObject {
    var id: String?
    var caption: String
    var imageUrl: String
    var user: String
    
    let captionKey = "caption"
    let urlKey = "imageUrl"
    let userKey = "user"
    
    init(caption: String, imageUrl: String, user: String) {
        self.caption = caption
        self.imageUrl = imageUrl
        self.user = user
    }
    
    init(documentSnapshot: DocumentSnapshot) {
        self.id = documentSnapshot.documentID
        let data = documentSnapshot.data()!
        self.caption = data[captionKey] as! String
        self.imageUrl = data[urlKey] as! String
        self.user = data[userKey] as! String
    }
    
    var data: [String: Any] {
        return [captionKey: self.caption,
                urlKey: self.imageUrl,
                userKey: self.user]
    }
}
