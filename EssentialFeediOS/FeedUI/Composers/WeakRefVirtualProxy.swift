//
//  WeakRefVirtualProxy.swift
//  EssentialFeediOS
//
//  Created by Josip Petric on 30.08.2023..
//

import UIKit
import EssentialFeed

final class WeakRefVirtualProxy<T: AnyObject> {
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
