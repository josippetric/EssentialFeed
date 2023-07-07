//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Josip Petric on 07.07.2023..
//

import Foundation


public protocol FeedStore {
	typealias DeletionCompletion = (Error?) -> Void
	typealias InsertionCompletion = (Error?) -> Void

	func deleteCachedFeed(completion: @escaping DeletionCompletion)
	func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}
