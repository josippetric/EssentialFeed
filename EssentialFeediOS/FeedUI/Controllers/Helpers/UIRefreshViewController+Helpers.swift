//
//  UIRefreshViewController+Helpers.swift
//  EssentialFeediOS
//
//  Created by Josip Petric on 04.09.2023..
//

import Foundation
import UIKit

extension UIRefreshControl {
	func update(isRefreshing: Bool) {
		isRefreshing ? beginRefreshing() : endRefreshing()
	}
}
