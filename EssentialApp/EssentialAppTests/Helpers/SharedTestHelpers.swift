//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Josip Petric on 14.09.2023..
//

import Foundation

func anyData() -> Data {
	return Data("any data".utf8)
}

func anyNSError() -> NSError {
	return NSError(domain: "any", code: 100)
}

func anyURL() -> URL {
	return URL(string: "http://a-url.com")!
}
