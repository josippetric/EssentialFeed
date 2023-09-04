//
//  FeedErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by Josip Petric on 04.09.2023..
//

import Foundation

struct FeedErrorViewModel {
	let message: String?
	
	static var noError: FeedErrorViewModel {
		return FeedErrorViewModel(message: nil)
	}
	
	static func error(message: String) -> FeedErrorViewModel {
		return FeedErrorViewModel(message: message)
	}
}
