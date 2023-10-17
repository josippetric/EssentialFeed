//
//  ResourceErrorViewModel.swift
//  EssentialFeed
//
//  Created by Josip Petric on 04.09.2023..
//

import Foundation

public struct ResourceErrorViewModel {
	public let message: String?
	
	static var noError: ResourceErrorViewModel {
		return ResourceErrorViewModel(message: nil)
	}
	
	static func error(message: String) -> ResourceErrorViewModel {
		return ResourceErrorViewModel(message: message)
	}
}
