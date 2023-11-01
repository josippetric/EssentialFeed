//
//  FeedViewController+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Josip Petric on 19.09.2023..
//

import Foundation
import EssentialFeediOS
import UIKit

extension ListViewController {
	public override func loadViewIfNeeded() {
		super.loadViewIfNeeded()
		
		tableView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
	}
	
	func simulateErrorViewTap() {
		errorView.simulateTap()
	}
	
	func simulateUserInitiatedReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
	
	var errorMessage: String? {
		return errorView.message
	}
	
	func numberOfRows(in section: Int) -> Int {
		tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: section)
	}
	
	func cell(row: Int, section: Int) -> UITableViewCell? {
		guard numberOfRows(in: section) > row else {
			return nil
		}
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: section)
		return ds?.tableView(tableView, cellForRowAt: index)
	}
}

extension ListViewController {
	func numberOfRenderedComments() -> Int {
		numberOfRows(in: commentsSection)
	}
	
	func commentMessage(at row: Int) -> String? {
		commentView(at: row)?.messageLabel?.text
	}
	
	func commentDate(at row: Int) -> String? {
		commentView(at: row)?.dateLabel?.text
	}
	
	func commentUsername(at row: Int) -> String? {
		commentView(at: row)?.usernameLabel?.text
	}
	
	private var commentsSection: Int {
		return 0
	}
	
	private func commentView(at row: Int) -> ImageCommentCell? {
		return cell(row: row, section: commentsSection) as? ImageCommentCell
	}
}

extension ListViewController {
	
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
	
	func simulateTapOnFeedImage(at row: Int) {
		let delegate = tableView.delegate
		let index = IndexPath(row: row, section: feedImageSection)
		delegate?.tableView?(tableView, didSelectRowAt: index)
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
	
	func renderedFeedImageData(at index: Int) -> Data? {
		simulateFeedImageViewVisible(at: index)?.renderedImage
	}
	
	func numberOfRenderedFeedImageViews() -> Int {
		numberOfRows(in: feedImageSection)
	}
	
	func feedImageView(at row: Int) -> UITableViewCell? {
		return cell(row: row, section: feedImageSection)
	}
	
	private var feedImageSection: Int {
		return 0
	}
}
