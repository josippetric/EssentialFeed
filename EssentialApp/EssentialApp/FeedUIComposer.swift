//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Josip Petric on 24.08.2023..
//

import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

public final class FeedUIComposer {
	private init() {}
	
	public static func feedComposedWith(
		feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>,
		imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) -> FeedViewController
	{
		let presentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>(
			loader: { feedLoader().dispatchOnMainQueue() })
		
		let feedController = makeFeedViewController(
			delegate: presentationAdapter,
			title: FeedPresenter.title )
		
		let presenter = LoadResourcePresenter(
			resourceView: FeedViewAdapter(
				controller: feedController,
				loader: { imageLoader($0).dispatchOnMainQueue() }),
			loadingView: WeakRefVirtualProxy(object: feedController),
			errorView: WeakRefVirtualProxy(object: feedController),
			mapper: FeedPresenter.map
		)
		presentationAdapter.presenter = presenter
		
		return feedController
	}
	
	private static func makeFeedViewController(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
		let bundle = Bundle(for: FeedViewController.self)
		let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
		let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
		feedController.delegate = delegate
		feedController.title = FeedPresenter.title
		return feedController
	}
}
