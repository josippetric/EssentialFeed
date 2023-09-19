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

	let localStoreURL = NSPersistentContainer
		.defaultDirectoryURL()
		.appendingPathComponent("feed-store.sqlite")

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let _ = (scene as? UIWindowScene) else { return }
		
		configureWindow()
	}
	
	func configureWindow() {
		// Setting up remote loaders
		let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
		let remoteClient = makeRemoteClient()
		let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: remoteClient)
		let remoteImageDataLoader = RemoteFeedImageDataLoader(client: remoteClient)

		// Setting up local loaders
		let localStore = try! CoreDataFeedStore(storeURL: localStoreURL)
		let localFeedLoader = LocalFeedLoader(store: localStore, currentDate: Date.init)
		let localImageDataLoader = LocalFeedImageDataLoader(store: localStore)

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
	
	func makeRemoteClient() -> HTTPClient {
		return URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
	}
}
