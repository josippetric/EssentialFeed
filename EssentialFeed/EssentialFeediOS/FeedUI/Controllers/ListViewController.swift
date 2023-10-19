//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Josip Petric on 22.08.2023..
//

import UIKit
import EssentialFeed

public protocol FeedViewControllerDelegate {
	func didRequestFeedRefresh()
}

public protocol CellControllerProtocol {
	func view(in tableView: UITableView) -> UITableViewCell
	func preload()
	func cancelLoad()
}

final public class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
	@IBOutlet private(set) public var errorView: ErrorView?
	
	public var delegate: FeedViewControllerDelegate?

	private var loadingControllers = [IndexPath: CellControllerProtocol]()
	
	private var tableModel: [CellControllerProtocol] = [] {
		didSet { tableView.reloadData() }
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		refresh()
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		tableView.sizeTableHeaderToFit()
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableModel.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return cellController(forRowAt: indexPath).view(in: tableView)
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
	
	private func cellController(forRowAt indexPath: IndexPath) -> CellControllerProtocol {
		let controller = tableModel[indexPath.row]
		loadingControllers[indexPath] = controller
		return controller
	}
	
	private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
		loadingControllers[indexPath]?.cancelLoad()
		loadingControllers[indexPath] = nil
	}
	
	@IBAction private func refresh() {
		delegate?.didRequestFeedRefresh()
	}
	
	public func display(_ viewControllers: [CellControllerProtocol]) {
		loadingControllers = [:]
		tableModel = viewControllers
	}
	
	// MARK: - FeedLoadingView
	
	public func display(_ viewModel: ResourceLoadingViewModel) {
		refreshControl?.update(isRefreshing: viewModel.isLoading)
	}
	
	// MARK: - FeedErrorView
	
	public func display(_ viewModel: ResourceErrorViewModel) {
		errorView?.message = viewModel.message
	}
}
