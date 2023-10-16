//
//  FeedLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Josip Petric on 13.09.2023..
//

// The file is not used, but is left here for the future reference and learning purposes

//import EssentialFeed
//
//public class FeedLoaderWithFallbackComposite: FeedLoader {
//	let primary: FeedLoader
//	let fallback: FeedLoader
//	
//	public init(primary: FeedLoader, fallback: FeedLoader) {
//		self.primary = primary
//		self.fallback = fallback
//	}
//	
//	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
//		primary.load { [weak self] result in
//			switch result {
//			case .success:
//				completion(result)
//
//			case .failure:
//				self?.fallback.load(completion: completion)
//			}
//		}
//	}
//}
