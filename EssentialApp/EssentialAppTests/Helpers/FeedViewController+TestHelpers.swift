//
//  FeedViewController+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Josip Petric on 19.09.2023..
//

import Foundation
import EssentialFeediOS
import UIKit

extension FeedViewController {
	func simulateUserInitiatedFeedReload() {
		refreshControl?.simulatePullToRefresh()
	}

	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
	
	var errorMessage: String? {
		return errorView?.message
	}
	
	@discardableResult
	func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
		return feedImageView(at: index) as? FeedImageCell
	}
	
	@discardableResult
	func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
		let view = simulateFeedImageViewVisible(at: row)
		
		let delegate = tableView.delegate
		let index = IndexPath(row: row, section: feedImageSection)
		delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
		
		return view
	}
	
	func simulateFeedImageViewNearVisible(at row: Int) {
		let ds = tableView.prefetchDataSource
		let index = IndexPath(row: row, section: feedImageSection)
		ds?.tableView(tableView, prefetchRowsAt: [index])
	}
	
	func simulateFeedImageViewNotNearVisible(at row: Int) {
		simulateFeedImageViewNearVisible(at: row)
		
		let ds = tableView.prefetchDataSource
		let index = IndexPath(row: row, section: feedImageSection)
		ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
	}
	
	func numberOfRenderedFeedImageViews() -> Int {
		return tableView.numberOfRows(inSection: feedImageSection)
	}
	
	func feedImageView(at row: Int) -> UITableViewCell? {
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: feedImageSection)
		return ds?.tableView(tableView, cellForRowAt: index)
	}
	
	private var feedImageSection: Int {
		return 0
	}
}
