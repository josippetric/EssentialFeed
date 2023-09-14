//
//  FeedImageDataCacheDecorator.swift
//  EssentialApp
//
//  Created by Josip Petric on 14.09.2023..
//

import Foundation
import EssentialFeed

public class FeedImageDataCacheDecorator: FeedImageDataLoader {
	private let decoratee: FeedImageDataLoader
	private let cache: FeedImageDataCache
	
	public init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
		self.decoratee = decoratee
		self.cache = cache
	}
	
	public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> LoadImageDataTask {
		return decoratee.loadImageData(from: url) { [weak self] result in
			completion(result.map { imageData in
				self?.cache.save(data: imageData, for: url, completion: { _ in })
				return imageData
			})
		}
	}
}
