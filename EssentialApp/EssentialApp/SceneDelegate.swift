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


	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		// Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
		// If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
		// This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
		guard let _ = (scene as? UIWindowScene) else { return }
		
		// Setting up remote loaders
		let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
		let remoteClient = makeRemoteClient()
		let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: remoteClient)
		let remoteImageDataLoader = RemoteFeedImageDataLoader(client: remoteClient)

		// Setting up local loaders
		let localStoreURL = NSPersistentContainer
			.defaultDirectoryURL()
			.appendingPathComponent("feed-store.sqlite")
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

		window?.rootViewController = feedViewController
	}
	
	private func makeRemoteClient() -> HTTPClient {
		switch UserDefaults.standard.string(forKey: "connectivity") {
		case "offline":
			return AlwaysFailingHTTPClient()
			
		default:
			return URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
		}
	}
}

private class AlwaysFailingHTTPClient: HTTPClient {
	private class Task: HTTPClientTask {
		func cancel() {}
	}
	
	func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
		completion(.failure(NSError(domain: "offline", code: 0)))
		return Task()
	}
}
