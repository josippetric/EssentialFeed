//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Josip Petric on 21.06.2023..
//

import Foundation

public enum HTTPClientResult {
	case success(Data, HTTPURLResponse)
	case failure(Error)
}

public protocol HTTPClient {
	func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
