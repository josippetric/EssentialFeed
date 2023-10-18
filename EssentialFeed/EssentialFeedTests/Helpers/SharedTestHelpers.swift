//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 19.07.2023..
//

import Foundation
import EssentialFeed

func anyNSError() -> NSError {
	return NSError(domain: "any error", code: 0)
}


func anyURL() -> URL {
	return URL(string: "http://any-url.com")!
}

func anyData() -> Data {
	return Data("any data".utf8)
}

func uniqueImage() -> FeedImage {
	return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
	let feed = [uniqueImage(), uniqueImage()]
	let localFeed = feed.map({ LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) })
	return (feed, localFeed)
}

extension HTTPURLResponse {
	convenience init(statusCode: Int) {
		self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
	}
}

extension Date {
	func adding(seconds: TimeInterval) -> Date {
		return self + seconds
	}
	
	func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
		return calendar.date(byAdding: .day, value: days, to: self)!
	}
	
	func adding(minutes: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
		return calendar.date(byAdding: .minute, value: minutes, to: self)!
	}
}
