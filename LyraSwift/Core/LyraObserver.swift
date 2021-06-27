//
//  LyraObserver.swift
//  LyraSwift
//
//  Created by Tyler@work on 2021/6/26.
//  Copyright © 2021 LyraSwift. All rights reserved.
//

import ReSwift

public typealias LyraObserverSubscriber = LyraObserver & StoreSubscriber

/// `LyraObserver` is a `ReSwift` state transponder
/// Therefore an `observer` is not only a subClass of `LyraObserver`,
/// but also a implmentation of `StoreSubscriber`. There have a easy
/// way to make sure you do that right, just let your `observer`
/// implement the `LyraObserverSubscriber` (aka. `LyraObserver & StoreSubscriber`)
///
/// `[Design your Observer]`
/// First at all, you have to create a function  `newState(state: StateType)`
/// in your `Observer`, because `Observer` is a `StoreSubscriber`
///
/// Now we have some principles or conventions for the design:
/// if you want to make the call like this:
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
/// make it Optional, because the work flow depending on `init()`. Even you put parameters
/// in your `init`, It won't be called.
///
open class LyraObserver {
    /// This `Observer` actrually owner
    weak var subscriber: AnySubscriber?
    /// The identify of Subscriber
    var subscriberIdentifier: SubscriberIdentifier!
    /// The identify of module
    var moduleIdentify: LyraModuleIdentify!
    
    /// get a descriptive identify of current class
    static public var identify: String {
        String(describing: Self.self)
    }
    
    required public init() {}
    
    
    /// you can use it like that:
    /// ```
    ///     func newState(state: StateType) {
    ///         super.newState(state: state)
    ///         // your code
    ///     }
    /// ```
    /// the only thing it can do now is auto clean
    /// the subscription. Therefor i will advise use
    /// it as you build your `LyraObserver`
    /// - Parameter state: the `stateType` (`ReSwift`)
    public func newState<stateType>(state: stateType) {
        autoCleaner(state: state)
    }
    
    /// auto cleaner the unuseable subscription
    /// it will clean the subscription, when `subscriber ` is `nil`
    /// - Parameter state: the `stateType` (`ReSwift`)
    func autoCleaner<stateType>(state: stateType) {
        if subscriber != nil {
            return
        }
        Lyra.G.removeSubscription(subscriberIdentifier, for: moduleIdentify, with: stateType.self)
    }
}
