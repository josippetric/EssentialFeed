//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Josip Petric on 21.09.2023..
//

import XCTest
import EssentialFeediOS

final class FeedSnapshotTests: XCTestCase {
	
	func test_emptyFeed() {
		let sut = makeSUT()
		
		sut.display(emptyFeed())
		
		record(snapshot: sut.snapshot(), named: "EMPTY_FEED")
	}
	
	// MARK: - Helpers
	
	private func makeSUT() -> FeedViewController {
		let bundle = Bundle(for: FeedViewController.self)
		let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! FeedViewController
		return controller
	}
	
	private func emptyFeed() -> [FeedImageCellController] {
		return []
	}
	
	private func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
		guard let snapshotdata = snapshot.pngData() else {
			XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
			return
		}
		let snapshotURL = URL(fileURLWithPath: String(describing: file))
			.deletingLastPathComponent()
			.appending(path: "snapshots")
			.appending(path: "\(name).png")
		
		do {
			try FileManager.default.createDirectory(
				at: snapshotURL.deletingLastPathComponent(),
				withIntermediateDirectories: true
			)
			try snapshotdata.write(to: snapshotURL)
		} catch {
			XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
		}
	}
}

extension UIViewController {
	func snapshot() -> UIImage {
		let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
		return renderer.image { action in
			view.layer.render(in: action.cgContext)
		}
	}
}
