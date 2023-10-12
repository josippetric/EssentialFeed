//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Josip Petric on 14.09.2023..
//

import Foundation

public protocol FeedCache {
	typealias SaveResult = Result<Void, Error>

	func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void)
}
