//
//  RecievedData.swift
//  BalinaSoftTask
//
//  Created by Ilya on 24.08.22.
//

import Foundation

struct RecievedData: Decodable {
    let content: [PhotoTypeDtoOut]
    let page: Int
    let pageSize: Int
    let totalElements: Int
    let totalPages: Int
}
