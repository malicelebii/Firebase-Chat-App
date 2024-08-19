//
//  Conversation.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 19.08.2024.
//

import Foundation

struct Conversation {
    let id: String
    let latestMessage: LatestMessage
    let name: String
    let othetUserEmail: String
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}
