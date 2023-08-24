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
		let presenter = FeedPresenter(feedLoader: feedLoader)
		let refreshController = FeedRefreshViewController(presenter: presenter)
		let feedController = FeedViewController(refreshController: refreshController)
		
		presenter.loadingView = refreshController
		presenter.feedView = FeedViewAdapter(controller: feedController, loader: imageLoader)
		
		return feedController
	}
}

private final class FeedViewAdapter: FeedView {
	private weak var controller: FeedViewController?
	private let loader: FeedImageDataLoader
	
	init(controller: FeedViewController, loader: FeedImageDataLoader) {
		self.controller = controller
		self.loader = loader
	}
	
	func display(feed: [FeedImage]) {
		controller?.tableModel = feed.map {
			FeedImageCellController(
				model: FeedImageViewModel(
					model: $0, imageLoader: loader, imageTransformer: UIImage.init))
		}
	}
}
