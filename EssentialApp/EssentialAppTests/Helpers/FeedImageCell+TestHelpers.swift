//
//  FeedImageCell+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Josip Petric on 19.09.2023..
//

import Foundation
import EssentialFeediOS

extension FeedImageCell {
	func simulateRetryAction() {
		feedImageRetryButton?.simulateTap()
	}
	
	var isShowingLocation: Bool {
		return !locationContainer!.isHidden
	}
	
	var isShowingRetryAction: Bool {
		return !feedImageRetryButton!.isHidden
	}
	
	var locationText: String? {
		return locationLabel?.text
	}
	
	var descriptionText: String? {
		return descriptionLabel?.text
	}
	
	var isShowingImageLoadingIndicator: Bool {
		return feedImageContainer!.isShimmering
	}
	
	var renderedImage: Data? {
		return feedImageView?.image?.pngData()
	}
}
