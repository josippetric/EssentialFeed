//
//  FeedCacheTestsHelpers.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 19.07.2023..
//

import Foundation
import EssentialFeed

extension Date {
	func minusFeedCacheMaxAge() -> Date {
		return adding(days: -feedCacheMaxAgeInDays)
	}
	
	private var feedCacheMaxAgeInDays: Int {
		return 7
	}
}
