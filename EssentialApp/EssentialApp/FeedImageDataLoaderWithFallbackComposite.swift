//
//  FeedImageDataLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Josip Petric on 14.09.2023..
//

import Foundation
import EssentialFeed

public class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
	private let primary: FeedImageDataLoader
	private let fallback: FeedImageDataLoader
	
	private class TaskWrapper: LoadImageDataTask {
		var wrapped: LoadImageDataTask?
		
		func cancel() {
			wrapped?.cancel()
		}
	}
	
	public init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
		self.primary = primary
		self.fallback = fallback
	}
	
	public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> LoadImageDataTask {
		let task = TaskWrapper()
		
		task.wrapped = primary.loadImageData(from: url) { [weak self] result in
			switch result {
			case .success:
				completion(result)

			case .failure:
				task.wrapped = self?.fallback.loadImageData(from: url, completion: completion)
			}
		}
		return task
	}
}
