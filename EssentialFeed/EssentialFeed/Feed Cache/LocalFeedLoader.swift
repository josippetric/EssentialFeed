//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Josip Petric on 07.07.2023..
//

import Foundation

public final class LocalFeedLoader {
	let store: FeedStore
	private let currentDate: () -> Date
	
	public init(store: FeedStore, currentDate: @escaping () -> Date) {
		self.store = store
		self.currentDate = currentDate
	}
}

extension LocalFeedLoader: FeedCache {
	public typealias SaveResult = FeedCache.SaveResult

	public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
		store.deleteCachedFeed { [weak self] deletionResult in
			guard let self = self else { return }
			switch deletionResult {
			case .success:
				self.cache(feed, with: completion)

			case let .failure(error):
				completion(.failure(error))
			}
		}
	}

	private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
		store.insert(feed.toLocal(), timestamp: currentDate(), completion: { [weak self] error in
			guard self != nil else { return }
			completion(error)
		})
	}
}

extension LocalFeedLoader {
	public typealias LoadResult = Swift.Result<[FeedImage], Error>

	public func load(completion: @escaping (LoadResult) -> Void) {
		store.retrieve { [weak self] result in
			guard let self = self else { return }
			switch result {
			case let .failure(error):
				completion(.failure(error))
				
			case let .success(.some((feed, timestamp))) where FeedCachePolicy.validate(timestamp, against: self.currentDate()):
				completion(.success(feed.toModels()))
				
			case .success:
				completion(.success([]))
			}
		}
	}
}

extension LocalFeedLoader {
	public typealias ValidationResult = Result<Void, Error>
	
	public func validateCache(completion: @escaping (ValidationResult) -> Void) {
		store.retrieve { [weak self] result in
			guard let self = self else { return }
			
			switch result {
			case .failure:
				self.store.deleteCachedFeed(completion: completion)

			case let .success(.some((_, timestamp))) where !FeedCachePolicy.validate(timestamp, against: self.currentDate()):
				self.store.deleteCachedFeed(completion: completion)
				
			case .success:
				completion(.success(()))
			}
		}
	}
}

private extension Array where Element == FeedImage {
	func toLocal() -> [LocalFeedImage] {
		return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
	}
}

private extension Array where Element == LocalFeedImage {
	func toModels() -> [FeedImage] {
		return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
	}
}
