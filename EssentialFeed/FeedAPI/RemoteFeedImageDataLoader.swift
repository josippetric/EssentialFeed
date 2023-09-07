//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Josip Petric on 07.09.2023..
//

import Foundation

public final class RemoteFeedImageDataLoader: FeedImageDataLoader {
	public enum Error: Swift.Error {
		case invalidData
		case connectivity
	}
	
	private final class HTTPTaskWrapper: LoadImageDataTask {
		private var completion: ((FeedImageDataLoader.Result) -> Void)?

		var wrapped: HTTPClientTask?

		init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
			self.completion = completion
		}
		
		func complete(with result: FeedImageDataLoader.Result) {
			completion?(result)
		}
		
		func cancel() {
			preventFurtherCompletions()
			wrapped?.cancel()
		}
		
		private func preventFurtherCompletions() {
			completion = nil
		}
	}
	
	private let client: HTTPClient
	
	public init(client: HTTPClient) {
		self.client = client
	}
	
	public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> LoadImageDataTask {
		let task = HTTPTaskWrapper(completion)
		
		task.wrapped = client.get(from: url) { [weak self] result in
			guard self != nil else { return }
			
			task.complete(with: result
				.mapError { _ in Error.connectivity }
				.flatMap({ data, response in
					let isValidResponse = response.isOK && !data.isEmpty
					return isValidResponse ? .success(data) : .failure(Error.invalidData)
				})
			)
		}
		return task
	}
}
