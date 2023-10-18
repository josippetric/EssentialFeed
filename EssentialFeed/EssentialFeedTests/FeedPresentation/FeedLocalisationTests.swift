//
//  FeedLocalisationTests.swift
//  EssentialFeediOSTests
//
//  Created by Josip Petric on 29.08.2023..
//

import XCTest
import EssentialFeed

final class FeedLocalisationTests: XCTestCase {
	func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
		let table = "Feed"
		let bundle = Bundle(for: FeedPresenter.self)
		assertLocalizedKeyAndValuesExist(in: bundle, table)
	}
}
