//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Josip Petric on 24.08.2023..
//

import UIKit

final class FeedRefreshViewController: NSObject {
	private(set) lazy var view: UIRefreshControl = binded(UIRefreshControl())
	
	private let viewModel: FeedViewModel

	init(viewModel: FeedViewModel) {
		self.viewModel = viewModel
	}
	
	@objc func refresh() {
		viewModel.loadFeed()
	}
	
	private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
		viewModel.onChange = { viewModel in
			if viewModel.isLoading {
				view.beginRefreshing()
			} else {
				view.endRefreshing()
			}
		}
		view.addTarget(self, action: #selector(refresh), for: .valueChanged)
		return view
	}
}
