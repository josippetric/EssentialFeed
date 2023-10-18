//
//  FeedViewControllerTests+Localization.swift
//  EssentialFeediOSTests
//
//  Created by Josip Petric on 29.08.2023..
//

import Foundation
import XCTest
import EssentialFeed

extension FeedUIIntegrationTests {
	private class DummyView: ResourceView {
		func display(_ viewModel: Any) {}
	}
	
	var feedTitle: String {
		FeedPresenter.title
	}
	
	var loadError: String {
		LoadResourcePresenter<Any, DummyView>.loadError
	}
}
