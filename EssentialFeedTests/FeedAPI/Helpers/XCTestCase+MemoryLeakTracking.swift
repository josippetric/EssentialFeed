//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 26.06.2023..
//

import XCTest

extension XCTestCase {
	func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString, line: UInt) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(
				instance, "Instance should have been deallocated. Potential memory leak",
				file: file, line: line)
		}
	}
}