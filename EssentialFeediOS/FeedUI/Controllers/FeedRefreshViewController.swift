//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Josip Petric on 24.08.2023..
//

import UIKit

protocol FeedRefreshViewControllerDelegate {
	func didRequestFeedRefresh()
}

final class FeedRefreshViewController: NSObject, FeedLoadingView {
	private(set) lazy var view: UIRefreshControl = loadView()
	
	private let delegate: FeedRefreshViewControllerDelegate

	init(delegate: FeedRefreshViewControllerDelegate) {
		self.delegate = delegate
	}
	
	@objc func refresh() {
		delegate.didRequestFeedRefresh()
	}
	
	func display(_ viewModel: FeedLoadingViewModel) {
		viewModel.isLoading ? view.beginRefreshing() : view.endRefreshing()
	}
	
	private func loadView() -> UIRefreshControl {
		let view = UIRefreshControl()
		view.addTarget(self, action: #selector(refresh), for: .valueChanged)
		return view
	}
}
