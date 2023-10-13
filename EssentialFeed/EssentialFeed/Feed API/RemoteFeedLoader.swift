//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Josip Petric on 16.06.2023..
//

import Foundation

public typealias RemoteFeedLoader = RemoteLoader<[FeedImage]>

public extension RemoteFeedLoader {
	convenience init(url: URL, client: HTTPClient) {
		self.init(url: url, client: client, mapper: FeedItemsMapper.map)
	}
}
