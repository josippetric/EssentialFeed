//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Josip Petric on 14.09.2023..
//

import Foundation
import EssentialFeed

func anyData() -> Data {
	return Data("any data".utf8)
}

func anyNSError() -> NSError {
	return NSError(domain: "any", code: 100)
}

func anyURL() -> URL {
	return URL(string: "http://a-url.com")!
}

func uniqueFeed() -> [FeedImage] {
	return [FeedImage(id: UUID(), description: "any", location: "any location", url: URL(string: "http;//any-url.com")!)]
}

private class DummyView: ResourceView {
	func display(_ viewModel: Any) {}
}

var feedTitle: String {
	FeedPresenter.title
}

var loadError: String {
	LoadResourcePresenter<Any, DummyView>.loadError
}

var commentsTitle: String {
	ImageCommentsPresenter.title
}
