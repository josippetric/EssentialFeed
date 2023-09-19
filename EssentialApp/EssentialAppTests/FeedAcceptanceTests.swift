//
//  FeedAcceptanceTests.swift
//  EssentialAppTests
//
//  Created by Josip Petric on 19.09.2023..
//

import XCTest
import EssentialFeediOS
@testable import EssentialApp

final class FeedAcceptanceTests: XCTestCase {

	func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
//		let sut = SceneDelegate()
//		sut.window = UIWindow()
//		sut.configureWindow()
//		
//		let nav = sut.window?.rootViewController as? UINavigationController
//		let feed = nav?.topViewController as! FeedViewController
//		
//		XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 2)
//		XCTAssertNotNil(feed.simulateFeedImageViewVisible(at: 0)?.renderedImage)
//		XCTAssertNotNil(feed.simulateFeedImageViewVisible(at: 1)?.renderedImage)
	}

	func test_onLaunch_shouldDisplayCachedRemoteFeedWhenCustomerHasNoConnectivity() {

	}
	
	func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {

	}
}
