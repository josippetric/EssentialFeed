//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Josip Petric on 05.09.2023..
//

import Foundation

public final class FeedImagePresenter {
	
	public static func map(_ image: FeedImage) -> FeedImageViewModel {
		FeedImageViewModel(
			description: image.description,
			location: image.location)
	}
}
