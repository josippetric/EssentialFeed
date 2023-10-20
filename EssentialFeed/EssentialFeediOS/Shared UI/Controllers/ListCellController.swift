//
//  ListCellController.swift
//  EssentialFeediOSTests
//
//  Created by Josip Petric on 20.10.2023..
//

import UIKit

public struct ListCellController {
	let dataSource: UITableViewDataSource
	let delegate: UITableViewDelegate?
	let prefetching: UITableViewDataSourcePrefetching?
	
	public init(_ dataSource: UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching) {
		self.dataSource = dataSource
		self.delegate = dataSource
		self.prefetching = dataSource
	}
	
	public init(_ dataSource: UITableViewDataSource) {
		self.dataSource = dataSource
		self.delegate = nil
		self.prefetching = nil
	}
}
