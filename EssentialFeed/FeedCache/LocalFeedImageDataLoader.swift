//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Josip Petric on 07.09.2023..
//

import Foundation

public final class LocalFeedImageDataLoader {
	private final class Task: FeedImageDataLoaderTask {
		private var completion: ((FeedImageDataLoader.Result) -> Void)?
		
		init(completion: @escaping (FeedImageDataLoader.Result) -> Void) {
			self.completion = completion
		}
		
		func complete(with result: FeedImageDataLoader.Result) {
			completion?(result)
		}
		
		func cancel() {
			preventFurtherCompletions()
		}
		
		private func preventFurtherCompletions() {
			completion = nil
		}
	}
	
	public enum Error: Swift.Error {
		case failed
		case notFound
	}
	
	private let store: FeedImageDataStore
	
	public init(store: FeedImageDataStore) {
		self.store = store
	}
	
	public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
		let task = Task(completion: completion)
		store.retrieve(dataForURL: url, completion: { [weak self] result in
			guard self != nil else { return }

			task.complete(with: result
				.mapError({ _ in Error.failed })
				.flatMap({ data in data.map { .success($0) } ?? .failure(Error.notFound) })
			)
		})
		return task
	}
}
