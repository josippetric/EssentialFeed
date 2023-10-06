//
//  MainQueueDispatchDecorator.swift
//  EssentialFeediOS
//
//  Created by Josip Petric on 30.08.2023..
//

// The file is not used, but is left here for the future reference and learning purposes

import Foundation
import EssentialFeed

final class MainQueueDispatchDecorator<T> {
	private let decoratee: T
	
	init(decoratee: T) {
		self.decoratee = decoratee
	}

	func dispatch(completion: @escaping () -> Void) {
		guard Thread.isMainThread else {
			return DispatchQueue.main.async { completion() }
		}
		completion()
	}
}

extension MainQueueDispatchDecorator: FeedLoader where T == FeedLoader {
	func load(completion: @escaping (FeedLoader.Result) -> Void) {
		decoratee.load { [weak self] result in
			self?.dispatch { completion(result) }
		}
	}
}

extension MainQueueDispatchDecorator: FeedImageDataLoader where T == FeedImageDataLoader {
	func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
		decoratee.loadImageData(from: url) { [weak self] result in
			self?.dispatch { completion(result) }
		}
	}
}
