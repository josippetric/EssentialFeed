//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Josip Petric on 05.09.2023..
//

import Foundation

public struct FeedImageViewModel {
	public let description: String?
	public let location: String?
	
	public var hasLocation: Bool {
		return location != nil
	}
}
