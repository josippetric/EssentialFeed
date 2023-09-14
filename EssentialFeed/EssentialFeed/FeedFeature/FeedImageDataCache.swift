//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Josip Petric on 14.09.2023..
//

import Foundation

public protocol FeedImageDataCache {
	typealias SaveResult = Result<Void, Error>

	func save(data: Data, for url: URL, completion: @escaping (SaveResult) -> Void)
}
