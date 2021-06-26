//
//  LyraObserver.swift
//  LyraSwift
//
//  Created by Tyler@work on 2021/6/26.
//  Copyright © 2021 LyraSwift. All rights reserved.
//

import ReSwift

/// `LyraObserver` is a `ReSwift` state transponder
/// Therefore an `observer` is not only a subClass of `LyraObserver`,
/// but also a implmentation of `StoreSubscriber`. There have a easy
/// way to make sure you do that right, just let your `observer`
/// implement the protocol `LyraObserverSubscriber` (aka. `LyraObserver & StoreSubscriber`)
///
/// `[Design your Observer]`
/// First at all, you have to create a function  `newState(state: StateType)`
/// in your `Observer`, because `Observer` is a `StoreSubscriber`
///
/// Now we have some principles or conventions for the design:
/// 1. if you want to make the call like this:
/// ```
///    Lyra.module(\.search)
///         .subscriber(self)
///         .observer
///         .observerSomeState {
///             // some code
///         }
///  or:
///   Lyra.module(\.search)
///         .observe(self)
///         .observerSomeState {
///             // some code
///         }
/// ```
///
/// you should do that like:
///```
///  class SearchObserver: LyraObserverSubscriber {
///     var observerSomeStateClouser: ((String) -> ())?
///
///     func observerSomeState(_ clouser: @escaping (String) -> ()) -> Self {
///         self.observerSomeStateClouser = clouser
///         return self
///     }
///
///     func newState(state: SearchState) {
///         observerSomeStateClouser?(state.keyword)
///     }
///  }
///```
///
/// Last but not least, the properies of your `Observer` must have the default value or
/// make it Optional, because the work flow depending on `init()`. If you any parameters
/// in your `init`, It won't be called.
///
open class LyraObserver {
    /// This `Observer` actrually owner
    weak var subscriber: AnyObject?
    
    /// get a descriptive identify of current class
    static public var identify: String {
        String(describing: Self.self)
    }
    
    required public init() {}
}
