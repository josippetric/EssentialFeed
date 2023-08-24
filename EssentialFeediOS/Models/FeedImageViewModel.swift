//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Josip Petric on 24.08.2023..
//

import Foundation
import EssentialFeed

final class FeedImageViewModel<Image> {
	typealias Observer<T> = (T) -> Void
	
	var onImageLoad: Observer<Image>?
	var onImageLoadingStateChange: Observer<Bool>?
	var onShouldRetryImageLoadStateChange: Observer<Bool>?
	
	private var task: FeedImageDataLoaderTask?
	private let model: FeedImage
	private var imageLoader: FeedImageDataLoader
	private var imageTransformer: (Data) -> Image?
	
	init(model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
		self.model = model
		self.imageLoader = imageLoader
		self.imageTransformer = imageTransformer
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
		if let image = (try? result.get()).flatMap(imageTransformer) {
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
