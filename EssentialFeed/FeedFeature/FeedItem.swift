//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Josip Petric on 15.06.2023..
//

import Foundation

public struct FeedItem: Equatable {
	let id: UUID
	let description: String?
	let location: String?
	let imageURL: URL
}
