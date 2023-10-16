//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Josip Petric on 08.09.2023..
//

import UIKit
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
		let feedViewController = FeedUIComposer.feedComposedWith(
			feedLoader: makeRemoteFeedLoaderWithLocalFallback,
			imageLoader: makeLocalImageLoaderWithRemoteFallback
		)

		window?.rootViewController = UINavigationController(rootViewController: feedViewController)
		window?.makeKeyAndVisible()
	}
	
	func sceneWillResignActive(_ scene: UIScene) {
		localFeedLoader.validateCache { _ in }
	}
	
	private func makeRemoteFeedLoaderWithLocalFallback() -> FeedLoader.Publisher {
		let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
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
