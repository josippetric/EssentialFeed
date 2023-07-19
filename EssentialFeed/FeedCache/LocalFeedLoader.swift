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
	private let calendar = Calendar(identifier: .gregorian)
	private var maxCacheAgeInDays: Int {
		return 7
	}

	public typealias SaveResult = Error?
	public typealias LoadResult = LoadFeedResult

	public init(store: FeedStore, currentDate: @escaping () -> Date) {
		self.store = store
		self.currentDate = currentDate
	}

	public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
		store.deleteCachedFeed { [weak self] error in
			guard let self = self else { return }
			if let cacheDeletionError = error {
				completion(cacheDeletionError)
			} else {
				self.cache(feed, with: completion)
			}
		}
	}
	
	public func load(completion: @escaping (LoadResult) -> Void) {
		store.retrieve { [unowned self] result in
			switch result {
			case let .failure(error):
				self.store.deleteCachedFeed { _ in }
				completion(.failure(error))
				
			case let .found(feed, timestamp) where self.validate(timestamp):
				completion(.success(feed.toModels()))

			case .found, .empty:
				completion(.success([]))
			}
		}
	}
	
	private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
		store.insert(feed.toLocal(), timestamp: currentDate(), completion: { [weak self] error in
			guard self != nil else { return }
			completion(error)
		})
	}

	private func validate(_ timestamp: Date) -> Bool {
		guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
			return false
		}
		return currentDate() < maxCacheAge
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