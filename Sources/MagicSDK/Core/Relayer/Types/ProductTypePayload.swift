//
//  Payload.swift
//  
//
//  Created by Arian Flores - Magic on 9/21/23.
//

import Foundation

struct ProductTypePayload: Decodable {
    struct Response: Decodable {
        let product_type: String
    }
    
    let response: Response
}
