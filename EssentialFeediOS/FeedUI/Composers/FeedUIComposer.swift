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
		let refreshController = FeedRefreshViewController(delegate: presentationAdapter)
		let feedController = FeedViewController(refreshController: refreshController)
		
		let presenter = FeedPresenter(
			feedView: FeedViewAdapter(controller: feedController, loader: imageLoader),
			loadingView: WeakRefVirtualProxy(object: refreshController)
		)
		presentationAdapter.presenter = presenter
		
		return feedController
	}
	
	private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
		return { [weak controller] feed in
			controller?.tableModel = feed.map {
				FeedImageCellController(
					model: FeedImageViewModel(
						model: $0, imageLoader: loader, imageTransformer: UIImage.init))
			}
		}
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

private final class FeedViewAdapter: FeedView {
	private weak var controller: FeedViewController?
	private let loader: FeedImageDataLoader
	
	init(controller: FeedViewController, loader: FeedImageDataLoader) {
		self.controller = controller
		self.loader = loader
	}
	
	func display(_ viewModel: FeedViewModel) {
		controller?.tableModel = viewModel.feed.map {
			FeedImageCellController(
				model: FeedImageViewModel(
					model: $0, imageLoader: loader, imageTransformer: UIImage.init))
		}
	}
}

private class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
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
