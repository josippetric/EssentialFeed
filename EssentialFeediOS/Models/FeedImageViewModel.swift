//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Josip Petric on 24.08.2023..
//

import UIKit
import EssentialFeed

final class FeedImageViewModel {
	typealias Observer<T> = (T) -> Void
	
	var onImageLoad: Observer<UIImage>?
	var onImageLoadingStateChange: Observer<Bool>?
	var onShouldRetryImageLoadStateChange: Observer<Bool>?
	
	private var task: FeedImageDataLoaderTask?
	private let model: FeedImage
	private var imageLoader: FeedImageDataLoader
	
	init(model: FeedImage, imageLoader: FeedImageDataLoader) {
		self.model = model
		self.imageLoader = imageLoader
	}
	
	var description: String? {
		return model.description
	}
	
	var location: String? {
		return model.location
	}
	
	var hasLocation: Bool {
		return model.location != nil
	}

	func loadImageData() {
		onImageLoadingStateChange?(true)
		onShouldRetryImageLoadStateChange?(false)
		task = imageLoader.loadImageData(from: model.url, completion: { [weak self] result in
			self?.handle(result)
		})
	}
	
	private func handle(_ result: FeedImageDataLoader.Result) {
		if let image = (try? result.get()).flatMap(UIImage.init) {
			onImageLoad?(image)
		} else {
			onShouldRetryImageLoadStateChange?(true)
		}
		onImageLoadingStateChange?(false)
	}
	
	func cancelImageDataLoad() {
		task?.cancel()
		task = nil
	}
}
