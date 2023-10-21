//
//  ListCellController.swift
//  EssentialFeediOSTests
//
//  Created by Josip Petric on 20.10.2023..
//

import UIKit

public struct ListCellController {
	let id: AnyHashable
	let dataSource: UITableViewDataSource
	let delegate: UITableViewDelegate?
	let prefetching: UITableViewDataSourcePrefetching?
	
	public init(id: AnyHashable, _ dataSource: UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching) {
		self.id = id
		self.dataSource = dataSource
		self.delegate = dataSource
		self.prefetching = dataSource
	}
	
	public init(id: AnyHashable, _ dataSource: UITableViewDataSource) {
		self.id = id
		self.dataSource = dataSource
		self.delegate = nil
		self.prefetching = nil
	}
}

extension ListCellController: Equatable {
	public static func == (lhs: ListCellController, rhs: ListCellController) -> Bool {
		lhs.id == rhs.id
	}
}
extension ListCellController: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

