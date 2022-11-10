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
    
    private let storage = NSCache<Key, CachedObject<Object>>()
    
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
        self.storage.setObject(CachedObject(object), forKey: key)
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
        let now = Date()
        let cacheDate = object.cacheDate
        if now.timeIntervalSince(cacheDate) <= cacheDuration {
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
    private class CachedObject<O>: NSObject {
        let object: O
        let cacheDate: Date
        
        init(_ object: O) {
            self.object = object
            self.cacheDate = Date()
        }
    }
}

