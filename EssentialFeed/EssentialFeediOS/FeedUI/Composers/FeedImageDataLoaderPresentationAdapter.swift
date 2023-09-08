//
//  FeedImageDataLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Josip Petric on 30.08.2023..
//

import Foundation
import EssentialFeed

final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
	
	private var task: LoadImageDataTask?
	private let model: FeedImage
	private var imageLoader: FeedImageDataLoader
	
	var presenter: FeedImagePresenter<View, Image>?
	
	init(model: FeedImage, imageLoader: FeedImageDataLoader) {
		self.model = model
		self.imageLoader = imageLoader
	}
	
	func didRequestImage() {
		presenter?.didStartLoadingImageData(for: model)
		
		let model = self.model
		task = imageLoader.loadImageData(from: model.url, completion: { [weak self] result in
			switch result {
			case let .success(data):
				self?.presenter?.didFinishLoadingImageData(with: data, for: model)
				
			case let .failure(error):
				self?.presenter?.didFinishLoadingImageData(with: error, for: model)
			}
		})
	}
	
	func didCancelImageRequest() {
		task?.cancel()
	}
}
