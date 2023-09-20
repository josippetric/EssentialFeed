//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Josip Petric on 08.09.2023..
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import CoreData

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
	
	convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
		self.init()
		self.httpClient = httpClient
		self.store = store
	}

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let _ = (scene as? UIWindowScene) else { return }
		
		configureWindow()
	}
	
	func configureWindow() {
		// Setting up remote loaders
		let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
		let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: httpClient)
		let remoteImageDataLoader = RemoteFeedImageDataLoader(client: httpClient)

		// Setting up local loaders
		let localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
		let localImageDataLoader = LocalFeedImageDataLoader(store: store)

		let feedViewController = FeedUIComposer.feedComposedWith(
			feedLoader: FeedLoaderWithFallbackComposite(
				primary: FeedLoaderCacheDecorator(
					decoratee: remoteFeedLoader,
					cache: localFeedLoader),
				fallback: localFeedLoader),
			imageLoader: FeedImageDataLoaderWithFallbackComposite(
				primary: localImageDataLoader,
				fallback: FeedImageDataCacheDecorator(
					decoratee: remoteImageDataLoader,
					cache: localImageDataLoader)
			)
		)

		window?.rootViewController = UINavigationController(rootViewController: feedViewController)
	}
}
