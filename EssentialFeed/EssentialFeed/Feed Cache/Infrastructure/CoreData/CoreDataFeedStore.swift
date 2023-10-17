//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Josip Petric on 08.08.2023..
//

import Foundation
import CoreData

public final class CoreDataFeedStore {
	private static let modelName = "FeedStore"
	private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataFeedStore.self))
	
	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext
	
	enum StoreError: Error {
		case modelNotFound
		case failedToLoadPersistentStoreCoordinator(Error)
	}

	public init(storeURL: URL) throws {
		guard let model = CoreDataFeedStore.model else {
			throw StoreError.modelNotFound
		}
		do {
			container = try NSPersistentContainer.load(
				name: CoreDataFeedStore.modelName, model: model, url: storeURL)
			context = container.newBackgroundContext()
		} catch {
			throw StoreError.failedToLoadPersistentStoreCoordinator(error)
		}
	}
	
	func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
		let context = context
		context.perform {
			action(context)
		}
	}
	
	private func cleanUpReferencesToPersistenStores() {
		context.performAndWait {
			let coordinator = self.container.persistentStoreCoordinator
			try? coordinator.persistentStores.forEach(coordinator.remove)
		}
	}
	
	deinit {
		cleanUpReferencesToPersistenStores()
	}
}
