//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Josip Petric on 30.08.2023..
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: ResourceView {
	private weak var controller: ListViewController?
	private let loader: (URL) -> FeedImageDataLoader.Publisher
	
	init(controller: ListViewController, loader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
		self.controller = controller
		self.loader = loader
	}
	
	func display(_ viewModel: FeedViewModel) {
		controller?.display(viewModel.feed.map { model in
			let adapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>(loader: { [loader] in
				// Lookup: partial application of functions.
				// We are adapting function that takes no parameters to a function that
				// takes no parameters.
				// We apply the parameter that it expects
				loader(model.url)
			})

			let view = FeedImageCellController(
				viewModel:  FeedImagePresenter.map(model),
				delegate: adapter)
			adapter.presenter = LoadResourcePresenter(
				resourceView: WeakRefVirtualProxy(object: view),
				loadingView: WeakRefVirtualProxy(object: view),
				errorView: WeakRefVirtualProxy(object: view),
				mapper: { data in
					guard let image = UIImage(data: data) else {
						throw InvalidImageDataError()
					}
					return image
				}
			)

			return ListCellController(id: model, view)
		})
	}
}

private struct InvalidImageDataError: Error {}
