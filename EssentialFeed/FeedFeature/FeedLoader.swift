//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Josip Petric on 15.06.2023..
//

import Foundation

public protocol FeedLoader {
	typealias Result = Swift.Result<[FeedImage], Error>
	
	func load(completion: @escaping (Result) -> Void)
}
