//
//  UIButton+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Josip Petric on 19.09.2023..
//

import Foundation
import UIKit

extension UIButton {
	func simulateTap() {
		allTargets.forEach({ target in
			actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach({
				(target as NSObject).perform(Selector($0))
			})
		})
	}
}
