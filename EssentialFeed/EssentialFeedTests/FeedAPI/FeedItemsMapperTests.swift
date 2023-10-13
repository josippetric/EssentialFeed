//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Josip Petric on 15.06.2023..
//

import XCTest
@testable import EssentialFeed

final class FeedItemsMapperTests: XCTestCase {
	
	func test_map_throwsErrorOnNon200HttpResponse() throws {
		let json = makeItemsJson([])
		let samples = [199, 201, 300, 400, 401, 404, 500]
		
		try samples.forEach { code in
			XCTAssertThrowsError(
				try FeedItemsMapper.map(json, from: HTTPURLResponse(statusCode: code))
			)
		}
	}
	
	func test_map_throwsErrorOn200HttpResponseWithInvalidJson() {
		let invalidJson = Data("invalid data".utf8)
		
		XCTAssertThrowsError(
			try FeedItemsMapper.map(invalidJson, from: HTTPURLResponse(statusCode: 200))
		)
	}
	
	func test_map_deliversNoItemsOn200HttpResponseWithEmptyJsonList() throws {
		let emptyListJson = makeItemsJson([])
		
		let result = try FeedItemsMapper.map(emptyListJson, from: HTTPURLResponse(statusCode: 200))
		
		XCTAssertEqual(result, [])
	}
	
	func test_map_deliversItemsOn200HttpResponseWithJsonItems() throws {
		let item1 = makeItem(
			id: UUID(),
			imageUrl: URL(string: "https://a-given-url.com")!)
		
		let item2 = makeItem(
			id: UUID(),
			description: "A description",
			location: "A location",
			imageUrl: URL(string: "https://a-given-url.com")!)
		
		let items = [item1.model, item2.model]
		let json = makeItemsJson([item1.json, item2.json])
		
		let result = try FeedItemsMapper.map(json, from: HTTPURLResponse(statusCode: 200))
		XCTAssertEqual(result, items)
	}
	
	// MARK: - Helpers
	
	private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
		return .failure(error)
	}
	
	private func makeItem(
		id: UUID, description: String? = nil,
		location: String? = nil,
		imageUrl: URL
	) -> (model: FeedImage, json: [String: Any]) {
		
		let item = FeedImage(id: id, description: description, location: location, url: imageUrl)
		let json = [
			"id": id.uuidString,
			"description": description,
			"location": location,
			"image": imageUrl.absoluteString
		].compactMapValues({ $0 })
		return (item, json)
	}
	
	private func makeItemsJson(_ items: [[String: Any]]) -> Data {
		let json = ["items": items]
		return try! JSONSerialization.data(withJSONObject: json)
	}
}
