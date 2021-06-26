//
//  Lyra.swift
//  LyraSwift
//
//  Created by Tyler@work on 2021/6/26.
//  Copyright © 2021 LyraSwift. All rights reserved.
//

import ReSwift

public typealias AnySubscriber = AnyObject
public typealias SubscriberIdentifier = ObjectIdentifier
public typealias SubscriptionList = [SubscriberIdentifier: Subscription]
public typealias SubscriptionStore = [LyraModuleIdentify: SubscriptionList]

public class Subscription {
    private(set) weak var subscriber: AnySubscriber?
    /// An observer including all the closures from the subscriber
    /// And closures will peform when the module's Action is called
    let observer: LyraObserver?
    
    init(subscriber: AnySubscriber, observer: LyraObserver) {
        self.subscriber = subscriber
        self.observer = observer
    }
}

/// TODO: Comment
public class Lyra {
    fileprivate static let G = Lyra()
    /// Store all the Subscriptions of any modules.
    private(set) var subscriptions: SubscriptionStore = [:]
    
    /// A function for binding a module which you need, then you can do sth. like:
    /// 1. subscribe/unsubcirbe:
    ///     `Lyra.module(\.search).subscribe(self)`
    /// 2. call action:
    ///     `Lyra.module(\.search).action.keyword("Hello world")`
    /// 3. observe:
    ///     ```
    ///     Lyra.module(\.search).observe.keyword { keyword in
    ///         print("keyword is changed to: \(keyword)") // "keyword is changed to: Hello world"
    ///     }
    ///     ```
    /// - Parameter keyPath: A keyPath to `LyraStore` of some module
    /// - Returns: LyraDispatcher
    public static func module<M: LyraModule>(_ keyPath: KeyPath<LyraStore, M.Type>) -> LyraDispatcher<M>.Type {
        return LyraDispatcher<M>.self
    }
    
    /// Returns a Boolean value indicating whether the `subscriptions` contains an
    /// element that satisfies the given identify of module.
    ///
    /// - Parameter identify: the given identify
    /// - Returns: `true` if the `subscriptions` contains an element that satisfies
    ///   `identify`; otherwise, `false`.
    public func contains(module identify: LyraModuleIdentify) -> Bool {
        Lyra.G.subscriptions.contains(where: { $0.key == "\(identify)" })
    }
    
    /// Returns a Boolean value indicating whether the `subscriptions` contains an
    /// element that satisfies the given module(`M`) and identifier of `subscriber`.
    ///
    /// - Parameters:
    ///   - module: the given module
    ///   - subscriber: the given identifier of subscriber
    /// - Returns:  `true` if the `subscriptions` contains an element that satisfies
    ///   `moduel` and `subscriber`; otherwise, `false`.
    public static func contains<M: LyraModule>(module: M.Type, of subscriber: ObjectIdentifier) -> Bool {
        Lyra.G.subscriptions[M.identify]?[subscriber] != nil
    }
    
    /// Returns a Boolean value indicating whether the `subscriptions` contains an
    /// element that satisfies the given module(`M`) and `subscriber`.
    ///
    /// - Parameters:
    ///   - module: the given module
    ///   - subscriber: the given  subscriber
    /// - Returns:  `true` if the `subscriptions` contains an element that satisfies
    ///   `moduel` and `subscriptions`; otherwise, `false`.
    public static func contains<M: LyraModule>(module: M.Type, of subscriber: AnyObject) -> Bool {
        Self.contains(module: module, of: ObjectIdentifier(subscriber))
    }
    
    
    /// Return the subscriptionList of the given `module`
    /// - Parameter module: the given `module`
    /// - Returns: return the `SubscriptionList`
    public func subscriptionList<M: LyraModule>(from module: M.Type) -> SubscriptionList? {
        Lyra.G.subscriptions[M.identify]
    }
    
    
    /// Create a subscription that `subscriber` subscribe a `module` use the given `observer`
    /// - Parameters:
    ///   - subscriber: AnyObject
    ///   - module: Specified module
    ///   - Observer: An observer instance which type same as `module.Observer`
    func subscribe<M: LyraModule>(_ subscriber: AnyObject, for module: M.Type, use observer: M.Observer) {
        
        let subscription = Subscription(subscriber: subscriber, observer: observer)
        let mIdentifier = M.Observer.identify
        let sIdentifier = ObjectIdentifier(subscriber)
        /// Update the subscriptions (aka. dictionary)
        if Lyra.G.contains(module: mIdentifier) {
            Lyra.G.subscriptions[mIdentifier]![sIdentifier] = subscription
        } else {
            Lyra.G.subscriptions[mIdentifier] = [sIdentifier: subscription]
        }
    }
    
    /// unsubscribe a subscription of the `module` that satisfies
    /// the given subscriber.
    ///
    /// - Parameters:
    ///   - subscriber: the given  subscriber
    ///   - module: the given module
    func unsubscribe<M: LyraModule>(_ subscriber: AnyObject, for module: M.Type) {
        Lyra.G.removeSubscription(ObjectIdentifier(subscriber), for: M.self)
    }
    
    /// force remove a subscription of the `module` that satisfies
    /// the given subscriberIdentifier which indicating a subscriber.
    ///
    /// - Parameters:
    ///   - subscriberIdentifier: ObjectIdentifier of the subscriber
    ///   - module: the given module
    func removeSubscription<M: LyraModule>(_ subscriberIdentifier: ObjectIdentifier, for module: M.Type) {
        let module_identifier = M.Observer.identify
        if let shouldRemove = subscriptions[module_identifier]?.removeValue(forKey: subscriberIdentifier) {
            /// unsubscribe a Store from the ReSwift
            shouldRemove.observer?.ReUnsubscribe()
        }
    }
    
    /// Return a observer(`M.Observer`) that satisfies the given module(`M`)
    /// and `subscriber`
    /// - Parameters:
    ///   - module: the given module
    ///   - subscriber: the given  subscriber
    /// - Returns:  `true` if the `subscriptions` contains an element that satisfies
    ///   `moduel` and `subscriber`; otherwise, `false`.
    fileprivate static func observer<M: LyraModule>(of module: M.Type, for subscriber: AnyObject) -> M.Observer? {
        Lyra.G.subscriptions[M.identify]?[ObjectIdentifier(subscriber)]?.observer as? M.Observer
    }
}


/// TODO: Comment
public class LyraDispatcher<M: LyraModule> {
    
    /// An convenience way to call actions from module like that:
    /// ```
    ///     Lyra.module(\.search).action.placeholder("Hello world!")
    /// ```
    ///
    public static var action: M.Action.Type {
        M.Action.self
    }
    
    /// Return an `observer` instance from the module (`M`) of subscription that `subscriber` subscribe.
    ///
    /// - Parameter subscriber: the given subscriber
    /// - Returns: Return the `observer` that only belong the `subscriber`
    public static func subscribe(_ subscriber: AnyObject) -> M.Observer {
        var observer: M.Observer!
        if Lyra.contains(module: M.self, of: subscriber) {
            observer = Lyra.observer(of: M.self, for: subscriber)
        } else {
            observer = subscribeNewModule(subscriber)
        }
        return observer
    }
    
    /// Unsubscibe the module(`M`) from `subscriber`
    ///
    /// - Parameter subscriber: AnyObject
    public static func unsubscribe(_ subscriber: AnyObject) {
        Lyra.G.unsubscribe(subscriber, for: M.self)
    }
    
    private static func subscribeNewModule(_ subscriber: AnyObject) -> M.Observer {
        let observer = M.Observer()
        observer.ReSubscribe()
        Lyra.G.subscribe(subscriber, for: M.self, use: observer)
        observer.subscriber = subscriber
        return observer
    }
    
    /// Find all the Observer(`M.Observer`) that belong to the module
    /// and iterate pefrom it immediately.
    ///
    /// In the same time, it check if the subscriber is `nil`,
    /// if so, remove it.
    ///
    /// use it like that:
    /// ```
    ///     Lyra.module(\.someModule).ForEach { observer in
    ///         // somecode
    ///     }
    /// ```
    ///
    /// - Parameter handler: ForEach handler
    /// - Returns:
    public static func ForEach(_ handler: @escaping (M.Observer) -> ()) {
        guard let subscription = Lyra.G.subscriptionList(from: M.self) else {
            return
        }
        
        subscription.forEach {
            guard let observer = $0.value.observer as? M.Observer else {
                return
            }
            
            guard let _ = observer.subscriber else {
                /// Remove the subscription as the `subscriber` is `nil`
                Lyra.G.removeSubscription($0.key, for: M.self)
                return
            }
            /// peform
            handler(observer)
        }
    }
    
    public static func action(_ closure: (M.Action.Type) -> Action ) {
        
    }
}
