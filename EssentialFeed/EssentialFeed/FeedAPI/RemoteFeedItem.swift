//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Josip Petric on 17.07.2023..
//

import Foundation

struct RemoteFeedItem: Decodable {
	let id: UUID
	let description: String?
	let location: String?
	let image: URL
}
