//
//  FeedImageViewPresenter.swift
//  EssentialFeediOS
//
//  Created by Josip Petric on 24.08.2023..
//

import Foundation
import EssentialFeed

protocol FeedImageView {
	associatedtype Image

	func display(_ viewModel: FeedImageViewModel<Image>)
}

final class FeedImagePresesnter<View: FeedImageView, Image> where View.Image == Image {
	typealias Observer<T> = (T) -> Void
	
	private let view: View
	private var imageTransformer: (Data) -> Image?
	
	init(view: View, imageTransformer: @escaping (Data) -> Image?) {
		self.view = view
		self.imageTransformer = imageTransformer
	}
	
	func didStartLoadingImageData(for model: FeedImage) {
		view.display(FeedImageViewModel(
			description: model.description,
			location: model.location,
			image: nil,
			isLoading: true,
			shouldRetry: false))
	}
	
	private struct InvalidImageDataError: Error {}
	
	func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
		guard let image = imageTransformer(data) else {
			return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
		}
		view.display(FeedImageViewModel(
			description: model.description,
			location: model.location,
			image: image,
			isLoading: false,
			shouldRetry: false))
	}
	
	func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
		view.display(FeedImageViewModel(
			description: model.description,
			location: model.location,
			image: nil,
			isLoading: false,
			shouldRetry: true))
	}
}
