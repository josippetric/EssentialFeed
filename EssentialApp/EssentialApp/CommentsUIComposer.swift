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
	
	private typealias CommentsPresentationAdapter = LoadResourcePresentationAdapter<[ImageComment], CommentsViewAdapter>
	
	public static func commentsComposedWith(
		commentsLoader: @escaping () -> AnyPublisher<[ImageComment], Error>)
	-> ListViewController {
		let presentationAdapter = CommentsPresentationAdapter(
			loader: { commentsLoader().dispatchOnMainQueue() })
		
		let commentsController = makeCommentsViewController(title: ImageCommentsPresenter.title )
		commentsController.onRefresh = presentationAdapter.loadResource
		
		let presenter = LoadResourcePresenter(
			resourceView: CommentsViewAdapter(controller: commentsController),
			loadingView: WeakRefVirtualProxy(object: commentsController),
			errorView: WeakRefVirtualProxy(object: commentsController),
			mapper: { ImageCommentsPresenter.map($0) }
		)
		presentationAdapter.presenter = presenter
		
		return commentsController
	}
	
	private static func makeCommentsViewController(title: String) -> ListViewController {
		let bundle = Bundle(for: ListViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! ListViewController
		controller.title = title
		return controller
	}
}

final class CommentsViewAdapter: ResourceView {
	private weak var controller: ListViewController?
	
	init(controller: ListViewController) {
		self.controller = controller
	}
	
	func display(_ viewModel: ImageCommentsViewModel) {
		controller?.display(viewModel.comments.map({ viewModel in
			ListCellController(id: viewModel, ImageCommentCellController(model: viewModel))
		}))
	}
}
