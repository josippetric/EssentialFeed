//
//  CommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Josip Petric on 24.10.2023..
//

import XCTest
import EssentialApp
import EssentialFeediOS
import EssentialFeed
import UIKit
import Combine

final class CommentsUIIntegrationTests: XCTestCase {

	func test_commentsView_hasTitle() {
		let (sut, _) = makeSUT()
		
		sut.loadViewIfNeeded()

		XCTAssertEqual(sut.title, commentsTitle)
	}

	func test_loadCommentsActions_requestCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		
		XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests before view is loaded")
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once view is loaded")

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected another loading request once user initiates a load")

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected another loading request once user initiates a load")
	}

	func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected a loading indicator once view is loaded")
		
		loader.completeCommentsLoading(at: 0)
		XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator once loading completes successfully")
		
		sut.simulateUserInitiatedReload()
		XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator once user initiates a reload")
		
		loader.completeCommentsLoadingWithError(at: 1)
		XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator once user initiated loading completes with an error")
	}

	func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
		let comment0 = makeComment(message: "a message", username: "a username")
		let comment1 = makeComment(message: "another message", username: "another username")
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()

		assertThat(sut, isRendering: [ImageComment]())
		
		loader.completeCommentsLoading(with: [comment0], at: 0)
		assertThat(sut, isRendering: [comment0])
		
		sut.simulateUserInitiatedReload()
		loader.completeCommentsLoading(with: [comment0, comment1], at: 1)
		assertThat(sut, isRendering: [comment0, comment1])
	}
	
	func test_loadCommentsCompletion_renderSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() {
		let comment = makeComment()
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeCommentsLoading(with: [comment], at: 0)
		assertThat(sut, isRendering: [comment])
		
		sut.simulateUserInitiatedReload()
		loader.completeCommentsLoading(with: [], at: 1)
		assertThat(sut, isRendering: [])
	}

	func test_loadCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
		let comment = makeComment()
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeCommentsLoading(with: [comment], at: 0)
		assertThat(sut, isRendering: [comment])
		
		sut.simulateUserInitiatedReload()
		loader.completeCommentsLoadingWithError(at: 1)
		assertThat(sut, isRendering: [comment])
	}


	func test_loadCommentsCompletion_dispatchesFromBackgroundToMainThread() {
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeeded()
		
		let exp = expectation(description: "Wait for background queue")
		DispatchQueue.global().async {
			loader.completeCommentsLoading(at: 0)
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}
	
	func test_loadCommentsCompletion_rendersErrorMessageOnErrorUntilNextReload() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.errorMessage, nil)
		
		loader.completeCommentsLoadingWithError(at: 0)
		XCTAssertEqual(sut.errorMessage, loadError)
		
		sut.simulateUserInitiatedReload()
		XCTAssertEqual(sut.errorMessage, nil)
	}
	
	func test_tapOnErrorView_hidesErrorMessage() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.errorMessage, nil)
		
		loader.completeCommentsLoadingWithError(at: 0)
		XCTAssertEqual(sut.errorMessage, loadError)
		
		sut.simulateErrorViewTap()
		XCTAssertEqual(sut.errorMessage, nil)
	}

	func test_deinit_cancelsRunningRequest() {
		var cancelCallCount = 0
		var sut: ListViewController?
		
		autoreleasepool {
			sut = CommentsUIComposer.commentsComposedWith {
				PassthroughSubject<[ImageComment], Error>()
					.handleEvents(receiveCancel: {
						cancelCallCount += 1
					})
					.eraseToAnyPublisher()
			}
			sut?.loadViewIfNeeded()
		}
		
		XCTAssertEqual(cancelCallCount, 0)
		
		sut = nil

		XCTAssertEqual(cancelCallCount, 1)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = CommentsUIComposer.commentsComposedWith(
			commentsLoader: loader.loadPublisher)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}
	
	private func makeComment(message: String = "any message", username: String = "any username", url: URL = URL(string: "http://any-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> ImageComment {
		return ImageComment(id: UUID(), message: message, createdAt: Date(), username: username)
	}
	
	private func assertThat(_ sut: ListViewController, isRendering comments: [ImageComment], file: StaticString = #filePath, line: UInt = #line) {
		sut.view.enforceLayoutCycle()
		
		guard sut.numberOfRenderedComments() == comments.count else {
			return XCTFail("Expected \(comments.count) comments, got \(sut.numberOfRenderedComments()) instead", file: file, line: line)
		}
		
		let viewModel = ImageCommentsPresenter.map(comments)
		
		viewModel.comments.enumerated().forEach { index, comment in
			XCTAssertEqual(sut.commentMessage(at: index), comment.message, "Message at \(index)", file: file, line: line)
			XCTAssertEqual(sut.commentDate(at: index), comment.date, "Date at \(index)", file: file, line: line)
			XCTAssertEqual(sut.commentUsername(at: index), comment.username, "Username at \(index)", file: file, line: line)
		}
	}
	
	private func assertThat(_ sut: ListViewController, hasViewConfiguredFor image: FeedImage, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
		let view = sut.feedImageView(at: index)
		
		guard let cell = view as? FeedImageCell else {
			XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
			return
		}
		let shouldLocationBeVisible = (image.location != nil)
		XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible, "Expected 'isShowingLocaton' to be \(shouldLocationBeVisible) for image view at index \(index)", file: file, line: line)
		
		XCTAssertEqual(cell.locationText, image.location, "Expected location text to be \(String(describing: image.location)) for image view at index \(index)", file: file, line: line)
		
		XCTAssertEqual(cell.descriptionText, image.description, "Expected description text to be \(String(describing: image.description)) for image view at index \(index)", file: file, line: line)
	}
	
	// MARK: - CommentsLoader
	
	private class LoaderSpy {
		private var requests = [PassthroughSubject<[ImageComment], Error>]()

		var loadCommentsCallCount: Int {
			return requests.count
		}
		
		func loadPublisher() -> AnyPublisher<[ImageComment], Error> {
			let publisher = PassthroughSubject<[ImageComment], Error>()
			requests.append(publisher)
			return publisher.eraseToAnyPublisher()
		}
		
		func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
			requests[index].send(comments)
		}
		
		func completeCommentsLoadingWithError(at index: Int = 0) {
			let error = NSError(domain: "an error", code: 0)
			requests[index].send(completion: .failure(error))
		}
	}
}
