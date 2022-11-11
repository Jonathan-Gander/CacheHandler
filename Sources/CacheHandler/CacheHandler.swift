//
//  CacheHandler.swift
//
//  Created by Jonathan Gander on 10.11.22.
//

import Foundation

public class CacheHandler<Key: AnyObject, Object> {

    let cacheDuration: TimeInterval // in seconds
    
    public enum ExpiredCachePolicy {
        case ReturnNil          // Return nil when cache expired
        case ReturnObject       // Return object anyway when cache expired
    }
    let expiredCachePolicy: ExpiredCachePolicy
    
    let storage = NSCache<Key, CachedObject<Object>>()
    
    // MARK: - Init
    
    /// Init cache handler
    /// - Parameters:
    ///   - cacheDuration: duration of object in cache (in seconds)
    ///   - expiredCachePolicy: expired cache policy: What to do when object is in cache but cache is expired? Check ExpiredCachePolicy Enum for details.
    public init(cacheDuration: TimeInterval = 3600,
         expiredCachePolicy: ExpiredCachePolicy = .ReturnNil
    ) {
        self.cacheDuration = cacheDuration <= 0 ? .infinity : cacheDuration
        self.expiredCachePolicy = expiredCachePolicy
    }

    // MARK: - Public functions
    
    /// Add or replace object in cache
    /// - Parameters:
    ///   - object: object to store in cache
    ///   - key: key to identify object
    public func addObject(_ object: Object, withKey key: Key) {
        self.storage.setObject(CachedObject(object, cacheDuration: self.cacheDuration, expiredCachePolicy: self.expiredCachePolicy), forKey: key)
    }
    
    /// Get object from cache. If cache duraction is expired (> cacheDuration), will remove object from cache.
    /// - Parameter key: key to identify object
    /// - Returns: stored object if it exists at key and cache duration is not expired. If cache duration is expired, returns object or nil according to expiredCachePolicy.
    public func getObject(withKey key: Key) -> Object? {
        
        // Object is not in cache
        guard let object = self.storage.object(forKey: key) else {
            return nil
        }
        
        // Check if cached object is still valid (its cache duration is not expired)
        if Utils.cacheAvailable(cacheDate: object.cacheDate, cacheDuration: self.cacheDuration) {
            return object.object
        }
        
        // Cache is expired ...
        
        // Remove object from cache
        self.storage.removeObject(forKey: key)
        
        // Check expired cache policy.
        switch expiredCachePolicy {
        case .ReturnNil:
            return nil
        case .ReturnObject:
            return object.object
        }
    }
    
    // MARK: - Class to store any Struct in cache
    class CachedObject<O>: NSObject, NSDiscardableContent {
        let object: O
        let cacheDate: Date
        let cacheDuration: TimeInterval
        let expiredCachePolicy: ExpiredCachePolicy
        
        init(_ object: O, cacheDuration: TimeInterval, expiredCachePolicy: ExpiredCachePolicy) {
            self.object = object
            self.cacheDate = Date()
            self.cacheDuration = cacheDuration
            self.expiredCachePolicy = expiredCachePolicy
        }
        
        func beginContentAccess() -> Bool {
            return Utils.cacheAvailable(cacheDate: self.cacheDate, cacheDuration: self.cacheDuration)
        }
        
        func endContentAccess() {}
        
        func discardContentIfPossible() {}
        
        func isContentDiscarded() -> Bool {
            
            // Check if cache is still available
            if Utils.cacheAvailable(cacheDate: self.cacheDate, cacheDuration: self.cacheDuration) {
                return false
            }
            
            // If not, discard object if expired cache policy is set to .ReturnNil
            return expiredCachePolicy == .ReturnNil
        }
    }
    
    private struct Utils {
        static func cacheAvailable(cacheDate: Date, cacheDuration: TimeInterval) -> Bool {
            let now = Date()
            return now.timeIntervalSince(cacheDate) <= cacheDuration
        }
    }
}
