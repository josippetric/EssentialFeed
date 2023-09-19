//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Josip Petric on 30.08.2023..
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: FeedView {
	private weak var controller: FeedViewController?
	private let loader: FeedImageDataLoader
	
	init(controller: FeedViewController, loader: FeedImageDataLoader) {
		self.controller = controller
		self.loader = loader
	}
	
	func display(_ viewModel: FeedViewModel) {
		controller?.display(viewModel.feed.map {
			let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(
				model: $0, imageLoader: loader
			)
			let view = FeedImageCellController(delegate: adapter)
			adapter.presenter = FeedImagePresenter(
				view: WeakRefVirtualProxy(object: view),
				imageTransformer: UIImage.init
			)
			return view
		})
	}
}
