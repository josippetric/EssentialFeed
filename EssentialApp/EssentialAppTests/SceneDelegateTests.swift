//
//  SceneDelegateTests.swift
//  EssentialAppTests
//
//  Created by Josip Petric on 19.09.2023..
//

import XCTest
import EssentialFeediOS
@testable import EssentialApp

final class SceneDelegateTests: XCTestCase {

	func test_sceneWillConnectToSession_configuresRootViewController() {
		let sut = SceneDelegate()
		sut.window = UIWindow()
		
		sut.configureWindow()
		
		let root = sut.window?.rootViewController
		let rootNavigation = root as? UINavigationController
		let topController = rootNavigation?.topViewController
		
		XCTAssertNotNil(rootNavigation, "Expected a navigation controller as root, got \(String(describing: root)) instead")
		XCTAssertTrue(topController is FeedViewController, "Expected a feed controller as to view controller, got \(String(describing: topController)) instead")
	}

}