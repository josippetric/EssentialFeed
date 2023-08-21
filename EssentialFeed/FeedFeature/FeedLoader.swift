//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Josip Petric on 15.06.2023..
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
	func load(completion: @escaping (LoadFeedResult) -> Void)
}
