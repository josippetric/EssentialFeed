//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Josip Petric on 08.09.2023..
//

import Foundation

extension CoreDataFeedStore: FeedStore {
	public func retrieve(completion: @escaping RetrievalCompletion) {
		perform { context in
			completion(Result(catching: {
				try ManagedCache.find(in: context).map {
					CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
				}
			}))
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		perform { context in
			completion(Result(catching: {
				let managedCache = try ManagedCache.newUniqueInstance(in: context)
				managedCache.timestamp = timestamp
				managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
				
				try context.save()
			}))
		}
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		perform { context in
			completion(Result(catching: {
				try ManagedCache.find(in: context).map({ context.delete($0) }).map({ try context.save() })
			}))
		}
	}
}
