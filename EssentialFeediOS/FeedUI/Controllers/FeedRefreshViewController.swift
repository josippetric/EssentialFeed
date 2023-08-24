//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Josip Petric on 24.08.2023..
//

import UIKit

final class FeedRefreshViewController: NSObject, FeedLoadingView {
	private(set) lazy var view: UIRefreshControl = loadView()
	
	private let presenter: FeedPresenter

	init(presenter: FeedPresenter) {
		self.presenter = presenter
	}
	
	@objc func refresh() {
		presenter.loadFeed()
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
