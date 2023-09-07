//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Josip Petric on 07.09.2023..
//

import Foundation

public protocol FeedImageDataStore {
	typealias Result = Swift.Result<Data?, Error>

	func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
