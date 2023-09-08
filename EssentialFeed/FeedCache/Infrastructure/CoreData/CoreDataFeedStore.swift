//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Josip Petric on 08.08.2023..
//

import Foundation
import CoreData

public final class CoreDataFeedStore {
	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext

	public init(storeURL: URL, bundle: Bundle = .main) throws {
		container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
		context = container.newBackgroundContext()
	}
	
	func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
		let context = context
		context.perform {
			action(context)
		}
	}
}
