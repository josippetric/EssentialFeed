//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Josip Petric on 08.09.2023..
//

import UIKit
import Combine
import CoreData
import EssentialFeed

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?
	
	private lazy var httpClient: HTTPClient = {
		URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
	}()
	private lazy var store: FeedStore & FeedImageDataStore = {
		try! CoreDataFeedStore(
			storeURL: NSPersistentContainer
				.defaultDirectoryURL()
				.appendingPathComponent("feed-store.sqlite"))
	}()
	private lazy var localFeedLoader: LocalFeedLoader = {
		LocalFeedLoader(store: store, currentDate: Date.init)
	}()
	
	private lazy var navigationController = UINavigationController(
		rootViewController: FeedUIComposer.feedComposedWith(
			   feedLoader: makeRemoteFeedLoaderWithLocalFallback,
			   imageLoader: makeLocalImageLoaderWithRemoteFallback,
			   selection: showComments
		   ))
	
	private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
	
	convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
		self.init()
		self.httpClient = httpClient
		self.store = store
	}

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let scene = (scene as? UIWindowScene) else { return }
	
		window = UIWindow(windowScene: scene)
		configureWindow()
	}
	
	func configureWindow() {
		window?.rootViewController = navigationController
		window?.makeKeyAndVisible()
	}
	
	func sceneWillResignActive(_ scene: UIScene) {
		localFeedLoader.validateCache { _ in }
	}
	
	private func showComments(for image: FeedImage) {
		let remoteURL = ImageCommentsEndpoint.get(image.id).url(baseURL: baseURL)
		let comments = CommentsUIComposer.commentsComposedWith(commentsLoader: makeRemoteCommentsLoader(url: remoteURL))
		navigationController.pushViewController(comments, animated: true)
	}
	
	private func makeRemoteCommentsLoader(url: URL) -> () -> AnyPublisher<[ImageComment], Error> {
		return { [httpClient] in
			return httpClient
				.getPublisher(url: url)
				.tryMap(ImageCommentsMapper.map)
				.eraseToAnyPublisher()
		}
	}
	
	private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<[FeedImage], Error> {
		let remoteURL = FeedEndpoint.get.url(baseURL: baseURL)
		// If not using combine we can create remote feed loader using the RemoteLoader, otherwise we can
		// even use universal abstractions in the Combine to not use RemoteLoader at all
		// let remoteFeedLoader = RemoteLoader<[FeedImage]>(url: remoteURL, client: httpClient, mapper: FeedItemsMapper.map)
		
		return httpClient
			.getPublisher(url: remoteURL)
			.tryMap(FeedItemsMapper.map)
			.caching(to: localFeedLoader)
			.fallback(to: localFeedLoader.loadPublisher)
	}
	
	private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
		let remoteImageDataLoader = RemoteFeedImageDataLoader(client: httpClient)
		let localImageDataLoader = LocalFeedImageDataLoader(store: store)
		
		return localImageDataLoader
			.loadImageDataPublisher(from: url)
			.fallback {
				remoteImageDataLoader
					.loadImageDataPublisher(from: url)
					.caching(to: localImageDataLoader, using: url)
			}
	}
}

// We don't need this any more since we have used combine to compose the architecture
// without using the RemoteLoader
// extension RemoteLoader: FeedLoader where Resource == [FeedImage] {}
