//
//  UIView+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Josip Petric on 26.09.2023..
//

import UIKit

extension UIView {
	func enforceLayoutCycle() {
		layoutIfNeeded()
		RunLoop.current.run(until: Date())
	}
}
