//
//  ManagedCache.swift
//  EssentialFeed
//
//  Created by Josip Petric on 16.08.2023..
//

import CoreData

@objc(ManagedCache)
class ManagedCache: NSManagedObject {
	@NSManaged var timestamp: Date
	@NSManaged var feed: NSOrderedSet
	
	static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
		let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
		request.returnsObjectsAsFaults = false
		return try context.fetch(request).first
	}
	
	static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
		try find(in: context).map({ context.delete($0) })
		return ManagedCache(context: context)
	}
	
	var localFeed: [LocalFeedImage] {
		return feed.compactMap({ ($0 as? ManagedFeedImage)?.local })
	}
}
