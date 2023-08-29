//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Josip Petric on 22.08.2023..
//

import UIKit

protocol FeedViewControllerDelegate {
	func didRequestFeedRefresh()
}

final public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching, FeedLoadingView {
	var tableModel: [FeedImageCellController] = [] {
		didSet { tableView.reloadData() }
	}
	var delegate: FeedViewControllerDelegate?
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		refresh()
		
		tableView.prefetchDataSource = self
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableModel.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return cellController(forRowAt: indexPath).view()
	}
	
	public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cancelCellControllerLoad(forRowAt: indexPath)
	}
	
	public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		indexPaths.forEach { indexPath in
			cellController(forRowAt: indexPath).preload()
		}
	}
	
	public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
		indexPaths.forEach(cancelCellControllerLoad)
	}
	
	private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
		return tableModel[indexPath.row]
	}
	
	private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
		cellController(forRowAt: indexPath).cancelLoad()
	}
	
	@IBAction private func refresh() {
		delegate?.didRequestFeedRefresh()
	}
	
	// MARK: - FeedLoadingView
	
	func display(_ viewModel: FeedLoadingViewModel) {
		viewModel.isLoading ? refreshControl?.beginRefreshing() : refreshControl?.endRefreshing()
	}
}
