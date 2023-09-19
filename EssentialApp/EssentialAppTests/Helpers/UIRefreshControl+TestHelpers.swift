//
//  UIRefreshControl+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Josip Petric on 19.09.2023..
//

import Foundation
import UIKit

extension UIRefreshControl {
	func simulatePullToRefresh() {
		allTargets.forEach({ target in
			actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({
				(target as NSObject).perform(Selector($0))
			})
		})
	}
}
