//
//  Message.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 14.08.2024.
//

import Foundation
import MessageKit

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType {
    var photoURL: String
    var senderId: String
    var displayName: String
}
