//
//  CombineHelpers.swift
//  EssentialApp
//
//  Created by Josip Petric on 06.10.2023..
//

import Foundation
import Combine
import EssentialFeed

public extension FeedImageDataLoader {
	typealias Publisher = AnyPublisher<Data, Error>
	
	func loadImageDataPublisher(from url: URL) -> Publisher {
		var task: FeedImageDataLoaderTask?

		return Deferred {
			Future { completion in
				task = self.loadImageData(from: url, completion: completion)
			}
		}
		.handleEvents(receiveCancel: { task?.cancel() })
		.eraseToAnyPublisher()
	}
}

extension Publisher where Output == Data {
	func caching(to cache: FeedImageDataCache, using url: URL) -> AnyPublisher<Output, Failure> {
		handleEvents(receiveOutput: { data in
			cache.saveIgnoringResult(data, for: url)
		})
		.eraseToAnyPublisher()
	}
}

private extension FeedImageDataCache {
	func saveIgnoringResult(_ data: Data, for url: URL) {
		save(data: data, for: url, completion: { _ in })
	}
}

public extension FeedLoader {
	typealias Publisher = AnyPublisher<[FeedImage], Error>

	func loadPublisher() -> Publisher {
		// Future is eaher publisher and it will be call as soon as someone calls the loadPublisher()
		// method. If that is not what we want, we can wrap it in Deferred publisher that will
		// only fire the event when someone subscribes on it.
		return Deferred {
			Future(self.load)
		}
		.eraseToAnyPublisher()
	}
}

extension Publisher where Output == [FeedImage] {
	func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
		handleEvents(receiveOutput: cache.saveIgnoringResult)
		.eraseToAnyPublisher()
		
		// Since handleEvents.receivedOutput closure has the same signature as
		// saveIgnoringResults we can just pass the function directly
	}
}

private extension FeedCache {
	func saveIgnoringResult(_ feed: [FeedImage]) {
		save(feed, completion: { _ in })
	}
}

extension Publisher {
	func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>) ->  AnyPublisher<Output, Failure> {
		self.catch { _ in fallbackPublisher() }.eraseToAnyPublisher()
	}
}

extension Publisher {
	func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
		receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler).eraseToAnyPublisher()
	}
}

extension DispatchQueue {
	
	static var immediateWhenOnMainQueueScheduler: ImmediateWhenOnMainScheduler {
		ImmediateWhenOnMainScheduler()
	}
	
	struct ImmediateWhenOnMainScheduler: Scheduler {
		typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
		typealias SchedulerOptions = DispatchQueue.SchedulerOptions

		var now: Self.SchedulerTimeType {
			DispatchQueue.main.now
		}

		var minimumTolerance: SchedulerTimeType.Stride {
			DispatchQueue.main.minimumTolerance
		}

		func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
			guard Thread.isMainThread else {
				return DispatchQueue.main.schedule(options: options, action)
			}
			action()
		}

		func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
			DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
		}

		func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
			DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
		}
	}
}
