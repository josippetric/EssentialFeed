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
	@IBOutlet private var view: UIRefreshControl?
	
	var delegate: FeedRefreshViewControllerDelegate?
	
	@IBAction func refresh() {
		delegate?.didRequestFeedRefresh()
	}
	
	func display(_ viewModel: FeedLoadingViewModel) {
		viewModel.isLoading ? view?.beginRefreshing() : view?.endRefreshing()
	}
}
