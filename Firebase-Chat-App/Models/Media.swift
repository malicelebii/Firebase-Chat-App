//
//  Media.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 20.08.2024.
//

import Foundation
import MessageKit

struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}
