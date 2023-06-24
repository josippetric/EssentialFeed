//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Josip Petric on 15.06.2023..
//

import Foundation

public enum LoadFeedResult {
	case success([FeedItem])
	case failure(Error)
}

public protocol FeedLoader {
	func load(completion: @escaping (LoadFeedResult) -> Void)
}
