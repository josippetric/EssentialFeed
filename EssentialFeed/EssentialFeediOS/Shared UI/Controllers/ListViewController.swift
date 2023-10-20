//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Josip Petric on 22.08.2023..
//

import UIKit
import EssentialFeed

public typealias ListCellController = UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching


final public class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
	@IBOutlet private(set) public var errorView: ErrorView?
	
	public var onRefresh: (() -> Void)?

	private var loadingControllers = [IndexPath: ListCellController]()
	
	private var tableModel: [ListCellController] = [] {
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
		let controller = cellController(forRowAt: indexPath)
		return controller.tableView(tableView, cellForRowAt: indexPath)
	}
	
	public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let controller = removeLoadingController(forRowAt: indexPath)
		controller?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
	}
	
	public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		indexPaths.forEach { indexPath in
			let controller = cellController(forRowAt: indexPath)
			controller.tableView(tableView, prefetchRowsAt: [indexPath])
		}
	}
	
	public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
		indexPaths.forEach { indexPath in
			let controller = removeLoadingController(forRowAt: indexPath)
			controller?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
		}
	}
	
	private func cellController(forRowAt indexPath: IndexPath) -> ListCellController {
		let controller = tableModel[indexPath.row]
		loadingControllers[indexPath] = controller
		return controller
	}
	
	private func removeLoadingController(forRowAt indexPath: IndexPath) -> ListCellController? {
		let controller = loadingControllers[indexPath]
		loadingControllers[indexPath] = nil
		return controller
	}
	
	@IBAction private func refresh() {
		onRefresh?()
	}
	
	public func display(_ viewControllers: [ListCellController]) {
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
