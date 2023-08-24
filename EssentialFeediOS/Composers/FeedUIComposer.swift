//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Josip Petric on 24.08.2023..
//

import Foundation
import EssentialFeed

public final class FeedUIComposer {
	private init() {}
	
	public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
		let feedViewModel = FeedViewModel(feedLoader: feedLoader)
		let refreshController = FeedRefreshViewController(viewModel: feedViewModel)
		let feedController = FeedViewController(refreshController: refreshController)
		
		// The closure here acts as an Adapter pattern since it transforms OR adapts
		// what refresh controller gives and what feed controller needs
		feedViewModel.onFeedLoad = adaptFeedToCellControllers(
			forwardingTo: feedController, loader: imageLoader
		)
		return feedController
	}
	
	private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
		return { [weak controller] feed in
			controller?.tableModel = feed.map {
				FeedImageCellController(
					model: FeedImageViewModel(model: $0, imageLoader: loader))
			}
		}
	}
}
