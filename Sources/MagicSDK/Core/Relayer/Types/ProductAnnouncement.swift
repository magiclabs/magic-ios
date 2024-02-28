//
//  ProductAnnouncement.swift
//
//
//  Created by Arian Flores - Magic on 2/27/24.
//

import Foundation

struct AnnouncementResponse: Codable {
    let msgType: String
    let response: AnnouncementResult
}

struct AnnouncementResult: Codable {
    let jsonrpc: String
    let id: Int?
    let result: AnnouncementMessage
}

struct AnnouncementMessage: Codable {
    let product_announcement: String
}

