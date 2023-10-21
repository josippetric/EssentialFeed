//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Josip Petric on 21.09.2023..
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

final class FeedSnapshotTests: XCTestCase {
	
	func test_feedWithContent() {
		let sut = makeSUT()
		
		sut.display(feedWithContent())
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_CONTENT_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_CONTENT_dark")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)), named: "FEED_WITH_CONTENT_light_extraExtraExtraLarge")
	}
	
	func test_feedWithFailedImageLoading() {
		let sut = makeSUT()
		
		sut.display(feedWithFailedImageLoading())
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_FAILED_IMAGE_LOADING_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_FAILED_IMAGE_LOADING_dark")
	}
	
	// MARK: - Helpers
	
	private func makeSUT() -> ListViewController {
		let bundle = Bundle(for: ListViewController.self)
		let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! ListViewController
		controller.loadViewIfNeeded()
		controller.tableView.showsVerticalScrollIndicator = false
		controller.tableView.showsHorizontalScrollIndicator = false
		return controller
	}

	private func feedWithContent() -> [ImageStub] {
		return [
			ImageStub(
				description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
				location: "East Side Gallery\nMemorial in Berlin, Germany",
				image: UIImage.make(withColor: .red)
			),
			ImageStub(
				description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
				location: "Garth Pier",
				image: UIImage.make(withColor: .green)
			)
		]
	}
	
	private func feedWithFailedImageLoading() -> [ImageStub] {
		return [
			ImageStub(
				description: nil,
				location: "Cannon Street, Londong",
				image: nil),
			ImageStub(
				description: nil,
				location: "Brighton Seafront",
				image: nil)
		]
	}
}

private extension ListViewController {
	func display(_ stubs: [ImageStub]) {
		let cells: [ListCellController] = stubs.map({ stub in
			let cellController = FeedImageCellController(viewModel: stub.viewModel, delegate: stub)
			stub.controller = cellController
			return ListCellController(id: UUID(), cellController)
		})
		
		display(cells)
	}
}

private class ImageStub: FeedImageCellControllerDelegate {
	let viewModel: FeedImageViewModel
	let image: UIImage?
	weak var controller: FeedImageCellController?
	
	init(description: String?, location: String?, image: UIImage?) {
		self.viewModel = FeedImageViewModel(
			description: description,
			location: location)
		self.image = image
	}
	
	func didRequestImage() {
		controller?.display(ResourceLoadingViewModel(isLoading: false))

		if let image = image {
			controller?.display(image)
			controller?.display(ResourceErrorViewModel(message: .none))
		} else {
			controller?.display(ResourceErrorViewModel(message: "Any."))
		}
	}
	
	func didCancelImageRequest() {}
}
