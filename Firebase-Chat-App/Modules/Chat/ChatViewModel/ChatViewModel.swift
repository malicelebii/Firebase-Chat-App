//
//  ChatViewModel.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 14.08.2024.
//

import Foundation

protocol ChatViewModelDelegate {
    
}

final class ChatViewModel {
    var messages = [Message]()
    let selfSender = Sender(photoURL: "", senderId: "1", displayName: "joe smith")

    init() {
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Hello world message")))
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Hello world message 2")))
    }
}
