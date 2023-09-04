//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 04.09.2023..
//

import XCTest

final class FeedImagePresenter {
	init(view: Any) {
		
	}
}

final class FeedImagePresenterTests: XCTestCase {
	
	func test_init_doesNotSendMessagesToView() {
		let (_, view) = makeSUT()
		
		XCTAssertTrue(view.messages.isEmpty, "Expected no view messages at init")
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = FeedImagePresenter(view: view)
		trackForMemoryLeaks(view)
		trackForMemoryLeaks(sut)
		return (sut, view)
	}
	
	private class ViewSpy {
		let messages: [Any] = []
	}
}
