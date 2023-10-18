//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 18.10.2023..
//

import XCTest
import EssentialFeed

final class ImageCommentsLocalizationTests: XCTestCase {

	func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
		let table = "ImageComments"
		let bundle = Bundle(for: ImageCommentsPresenter.self)
		assertLocalizedKeyAndValuesExist(in: bundle, table)
	}
}
