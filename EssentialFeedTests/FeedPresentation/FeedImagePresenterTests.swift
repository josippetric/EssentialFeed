//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 04.09.2023..
//

import XCTest
import EssentialFeed

struct FeedImageViewModel {
	let description: String?
	let location: String?
	let image: Any?
	let isLoading: Bool
	let shouldRetry: Bool
	
	var hasLocation: Bool {
		return location != nil
	}
}

protocol FeedImageView {
	func display(_ viewModel: FeedImageViewModel)
}

final class FeedImagePresenter {
	let view: FeedImageView
	
	init(view: FeedImageView) {
		self.view = view
	}
	
	func didStartLoadingImageData(for model: FeedImage) {
		view.display(FeedImageViewModel(
			description: model.description,
			location: model.location,
			image: nil,
			isLoading: true,
			shouldRetry: false))
	}
}

final class FeedImagePresenterTests: XCTestCase {
	
	func test_init_doesNotSendMessagesToView() {
		let (_, view) = makeSUT()
		
		XCTAssertTrue(view.messages.isEmpty, "Expected no view messages at init")
	}

	func test_didStartLoadingImageData_displaysLoadingImage() {
		let (sut, view) = makeSUT()
		let image = uniqueImage()
		
		sut.didStartLoadingImageData(for: uniqueImage())
		
		let message = view.messages.first
		XCTAssertEqual(view.messages.count, 1)
		XCTAssertEqual(message?.description, image.description)
		XCTAssertEqual(message?.location, image.location)
		XCTAssertEqual(message?.isLoading, true)
		XCTAssertEqual(message?.shouldRetry, false)
		XCTAssertNil(message?.image)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = FeedImagePresenter(view: view)
		trackForMemoryLeaks(view)
		trackForMemoryLeaks(sut)
		return (sut, view)
	}
	
	private class ViewSpy: FeedImageView {
		private(set) var messages: [FeedImageViewModel] = []
		
		func display(_ viewModel: FeedImageViewModel) {
			messages.append(viewModel)
		}
	}
}
