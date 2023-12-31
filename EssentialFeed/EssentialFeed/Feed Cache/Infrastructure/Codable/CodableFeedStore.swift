//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Josip Petric on 05.08.2023..
//

import Foundation

public final class CodableFeedStore: FeedStore {
	private struct Cache: Codable {
		let feed: [CodableFeedImage]
		let timestamp: Date
		 
		var localFeed: [LocalFeedImage] {
			return feed.map({ $0.local })
		}
	}
	
	private struct CodableFeedImage: Codable {
		let id: UUID
		let description: String?
		let location: String?
		let url: URL
		
		init(_ image: LocalFeedImage) {
			self.id = image.id
			self.description = image.description
			self.location = image.location
			self.url = image.url
		}
		
		var local: LocalFeedImage {
			return LocalFeedImage(id: id, description: description, location: location, url: url)
		}
	}
	
	private let queue = DispatchQueue(
		label: "\(CodableFeedStore.self)Queue",
		qos: .userInitiated, attributes: .concurrent)

	private let storeURL: URL
	
	public init(storeURL: URL) {
		self.storeURL = storeURL
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		// By storing storeURL in the scope of the method, we don't need to
		// use 'self' inside the async block and capture self.
		// Since storeURL is stored in the scope of the method and it is a value type, it is copied by value
		// so we only reference it's value inside the block, no need to capture the whole self
		let storeURL = storeURL
		queue.async {
			guard let data = try? Data(contentsOf: storeURL) else {
				return completion(.success(.none))
			}
			
			do {
				let decoder = JSONDecoder()
				let cache = try decoder.decode(Cache.self, from: data)
				completion(.success(.some((feed: cache.localFeed, timestamp: cache.timestamp))))
			} catch {
				completion(.failure(error))
			}
		}
	}

	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		let storeURL = storeURL
		queue.async(flags: .barrier) {
			do {
				let encoder = JSONEncoder()
				let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
				let encoded = try encoder.encode(cache)
				try encoded.write(to: storeURL)
				
				completion(.success(()))
			} catch {
				completion(.failure(error))
			}
		}
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		let storeURL = storeURL
		queue.async(flags: .barrier) {
			guard FileManager.default.fileExists(atPath: storeURL.path) else {
				return completion(.success(()))
			}
			do {
				try FileManager.default.removeItem(at: storeURL)
				completion(.success(()))
			} catch {
				completion(.failure(error))
			}
		}
	}
}
