//
//  CommentsUIComposer.swift
//  EssentialApp
//
//  Created by Josip Petric on 24.10.2023..
//

import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

public final class CommentsUIComposer {
	private init() {}
	
	public static func commentsComposedWith(
		commentsLoader: @escaping () -> AnyPublisher<[FeedImage], Error>)
	-> ListViewController {
		let presentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>(
			loader: { commentsLoader().dispatchOnMainQueue() })
		
		let feedController = makeFeedViewController(title: ImageCommentsPresenter.title )
		feedController.onRefresh = presentationAdapter.loadResource
		
		let presenter = LoadResourcePresenter(
			resourceView: FeedViewAdapter(
				controller: feedController,
				loader: { _ in Empty<Data, Error>().eraseToAnyPublisher() }),
			loadingView: WeakRefVirtualProxy(object: feedController),
			errorView: WeakRefVirtualProxy(object: feedController),
			mapper: FeedPresenter.map
		)
		presentationAdapter.presenter = presenter
		
		return feedController
	}
	
	private static func makeFeedViewController(title: String) -> ListViewController {
		let bundle = Bundle(for: ListViewController.self)
		let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
		let feedController = storyboard.instantiateInitialViewController() as! ListViewController
		feedController.title = title
		return feedController
	}
}

