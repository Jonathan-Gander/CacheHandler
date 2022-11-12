# A Swift cache handler
`CacheHandler` is a simple Swift package to handle a cache in your app. It uses `NSCache` as a storage but let you store structs objects. You can choose its key type (a class), its cache duration and expired cache policy (see below).

I've developed `CacheHandler` for my own usage as I needed to cache weather states from `WeatherKit`. I thought it might be useful for few of you.

## Usage 

### Installation

Add `CacheHandler` package to your project. 

In Xcode: `File` -> `Add Packages...` then enter my project GitHub URL:  
`https://github.com/Jonathan-Gander/CacheHandler`

### Import module
In file you want to use the cache handler:

```swift
import CacheHandler
```

### Create `CacheHandler`

Create your cache handler with a class used as a key and one as stored object. Stored objects can be `class` or `struct`.

As an example, let's say I have a `MyObject` struct that I want to store. And I will use a `NSString` as key.

```swift
struct MyObject {
    let name: String
    let age: Int
}

let cacheHandler = CacheHandler<NSString, MyObject>()
```

`CacheHandler` init takes two optional parameters:

- `cacheDuration`: (in seconds) Set how long an object can stay in the cache. After this duration, object will be removed from cache next time you try to get it.
- `expiredCachePolicy`: If you try to get an object that is expired (= it is in cache for more than `cacheDuration` seconds), you can choose if you get the object or if you get `nil`.

By default, `cacheDuration` is 3600 seconds (1 hour) and `expiredCachePolicy` is set to `.ReturnNil` to return a `nil` instead of object.

To change this, simply call init like this:

```swift
let cacheHandler = CacheHandler<NSString, MyObject>(cacheDuration: 60, expiredCachePolicy: .ReturnObject) // cache of 60 seconds only
```

### Store an object

To store an object in your `CacheHandler`, simply call `addObject` function: 

```swift
let object = MyObject(name: "Marvin", age: 42)
cacheHandler.addObject(object, withKey: "obj1")
```

### Get an object

To get an object from your `CacheHandler`, simply call "getObject` function: 

```swift
let object: MyObject? = cacheHandler.getObject(withKey: "obj1")
```

You can get the object if it is in cache and its cache duration is less or equal to `cacheDuration` seconds. Or if it is in cache, its cache duration is greater than `cacheDuration` seconds and `expiredCachePolicy` is set to `.ReturnObject`. In other cases, you get a `nil`.

## Licence

Be free to use my `CacheHandler` Package in your app. Licence is available [here](https://github.com/Jonathan-Gander/CacheHandler/blob/main/LICENSE). Please only add a copyright and licence notice.
