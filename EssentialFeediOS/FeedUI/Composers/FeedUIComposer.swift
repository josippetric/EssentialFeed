//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Josip Petric on 24.08.2023..
//

import UIKit
import EssentialFeed

public final class FeedUIComposer {
	private init() {}
	
	public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
		let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
		
		let bundle = Bundle(for: FeedViewController.self)
		let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
		let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
		feedController.delegate = presentationAdapter
		feedController.title = FeedPresenter.title
		
		let presenter = FeedPresenter(
			feedView: FeedViewAdapter(controller: feedController, loader: imageLoader),
			loadingView: WeakRefVirtualProxy(object: feedController)
		)
		presentationAdapter.presenter = presenter
		
		return feedController
	}
}

private final class WeakRefVirtualProxy<T: AnyObject> {
	private weak var object: T?
	
	init(object: T) {
		self.object = object
	}
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
	func display(_ viewModel: FeedLoadingViewModel) {
		object?.display(viewModel)
	}
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
	func display(_ viewModel: FeedImageViewModel<UIImage>) {
		object?.display(viewModel)
	}
}

private final class FeedViewAdapter: FeedView {
	private weak var controller: FeedViewController?
	private let loader: FeedImageDataLoader
	
	init(controller: FeedViewController, loader: FeedImageDataLoader) {
		self.controller = controller
		self.loader = loader
	}
	
	func display(_ viewModel: FeedViewModel) {
		controller?.tableModel = viewModel.feed.map {
			let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(
				model: $0, imageLoader: loader
			)
			let view = FeedImageCellController(delegate: adapter)
			adapter.presenter = FeedImagePresesnter(
				view: WeakRefVirtualProxy(object: view),
				imageTransformer: UIImage.init
			)
			return view
		}
	}
}

private class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
	private let feedLoader: FeedLoader
	var presenter: FeedPresenter?
	
	init(feedLoader: FeedLoader) {
		self.feedLoader = feedLoader
	}
	
	func didRequestFeedRefresh() {
		presenter?.didStartLoadingFeed()
		
		feedLoader.load { [weak self] result in
			switch result {
			case let .success(feed):
				self?.presenter?.didFinishLoadingFeed(with: feed)
			case let .failure(error):
				self?.presenter?.didFinishLoadingFeed(with: error)
			}
		}
	}
}

private class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
	
	private var task: FeedImageDataLoaderTask?
	private let model: FeedImage
	private var imageLoader: FeedImageDataLoader
	
	var presenter: FeedImagePresesnter<View, Image>?
	
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
