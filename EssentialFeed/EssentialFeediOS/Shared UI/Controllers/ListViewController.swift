//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Josip Petric on 22.08.2023..
//

import UIKit
import EssentialFeed

final public class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
	private(set) public var errorView = ErrorView()
	
	public var onRefresh: (() -> Void)?
	
	private lazy var dataSource: UITableViewDiffableDataSource<Int, ListCellController> = {
		.init(tableView: tableView) { tableView, indexPath, controller in
			return controller.dataSource.tableView(tableView, cellForRowAt: indexPath)
		}
	}()
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.dataSource = dataSource
		configureErrorView()
		refresh()
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		tableView.sizeTableHeaderToFit()
	}
	
	private func configureErrorView() {
		let container = UIView()
		container.backgroundColor = .clear
		container.addSubview(errorView)
		
		errorView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			errorView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
			errorView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
			errorView.topAnchor.constraint(equalTo: container.topAnchor),
			errorView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
		])
		
		tableView.tableHeaderView = container
		
		errorView.onHide = { [weak self] in
			self?.tableView.beginUpdates()
			self?.tableView.sizeTableHeaderToFit()
			self?.tableView.endUpdates()
		}
	}
	
	public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let dl = cellController(at: indexPath)?.delegate
		dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
	}
	
	public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		indexPaths.forEach { indexPath in
			let dsp = cellController(at: indexPath)?.prefetching
			dsp?.tableView(tableView, prefetchRowsAt: [indexPath])
		}
	}
	
	public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
		indexPaths.forEach { indexPath in
			let dsp = cellController(at: indexPath)?.prefetching
			dsp?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
		}
	}
	
	private func cellController(at indexPath: IndexPath) -> ListCellController? {
		dataSource.itemIdentifier(for: indexPath)
	}
	
	@IBAction private func refresh() {
		onRefresh?()
	}
	
	public func display(_ viewControllers: [ListCellController]) {
		var snapshot = NSDiffableDataSourceSnapshot<Int, ListCellController>()
		snapshot.appendSections([0])
		snapshot.appendItems(viewControllers, toSection: 0)
		dataSource.apply(snapshot)
	}
	
	// MARK: - FeedLoadingView
	
	public func display(_ viewModel: ResourceLoadingViewModel) {
		refreshControl?.update(isRefreshing: viewModel.isLoading)
	}
	
	// MARK: - FeedErrorView
	
	public func display(_ viewModel: ResourceErrorViewModel) {
		errorView.message = viewModel.message
	}
}
