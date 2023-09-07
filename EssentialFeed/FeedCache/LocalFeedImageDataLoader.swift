//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Josip Petric on 07.09.2023..
//

import Foundation

public final class LocalFeedImageDataLoader {
	private let store: FeedImageDataStore
	
	public init(store: FeedImageDataStore) {
		self.store = store
	}
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
	public typealias LoadResult = FeedImageDataLoader.Result
	
	public enum LoadError: Swift.Error {
		case failed
		case notFound
	}
	
	private final class Task: LoadImageDataTask {
		private var completion: ((LoadResult) -> Void)?
		
		init(completion: @escaping (LoadResult) -> Void) {
			self.completion = completion
		}
		
		func complete(with result: LoadResult) {
			completion?(result)
		}
		
		func cancel() {
			preventFurtherCompletions()
		}
		
		private func preventFurtherCompletions() {
			completion = nil
		}
	}
	
	public func loadImageData(from url: URL, completion: @escaping (LoadResult) -> Void) -> LoadImageDataTask {
		let task = Task(completion: completion)
		store.retrieve(dataForURL: url, completion: { [weak self] result in
			guard self != nil else { return }
			
			task.complete(with: result
				.mapError({ _ in LoadError.failed })
				.flatMap({ data in data.map { .success($0) } ?? .failure(LoadError.notFound) })
			)
		})
		return task
	}
}

extension LocalFeedImageDataLoader {
	public typealias SaveResult = Result<Void, Swift.Error>
	
	public func save(data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
		store.insert(data: data, for: url) { _ in }
	}
}
