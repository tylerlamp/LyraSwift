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


/// ` What's Lyra`
///   
///
public class Lyra {
    /// Global instance
    static let G = Lyra()
    /// Store all the Subscriptions of any modules.
    private(set) var subscriptions: SubscriptionStore = [:]
    /// Store all the store(`ReSwift`)
    private(set) var StoreStore: [LyraModuleIdentify: AnyObject] = [:]
    
    /// A function for binding a module which you need, then you can do sth. like:
    /// 1. subscribe/unsubcirbe:
    ///     `Lyra.module(\.search).subscribe(self)`
    /// 2. call action:
    /// ```
    ///     Lyra.module(\.search).action {
    ///         $0.keyword("Hello world")`
    ///     }
    /// ```
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
    public static func contains(module identify: LyraModuleIdentify) -> Bool {
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
    public static func contains<M: LyraModuleProtocol>(module: M.Type, of subscriber: SubscriberIdentifier) -> Bool {
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
    public static func contains<M: LyraModuleProtocol>(module: M.Type, of subscriber: AnyObject) -> Bool {
        Self.contains(module: module, of: SubscriberIdentifier(subscriber))
    }
    
    /// Return the subscriptionList of the given `module`
    /// - Parameter module: the given `module`
    /// - Returns: return the `SubscriptionList`
    func subscriptionList<M: LyraModuleProtocol>(from module: M.Type) -> SubscriptionList? {
        subscriptions[M.identify]
    }
    
    /// Create a subscription that `subscriber` subscribe a `module` use the given `observer`
    /// - Parameters:
    ///   - subscriber: AnyObject
    ///   - module: Specified module
    ///   - Observer: An observer instance which type same as `module.Observer`
    func subscribe<M: LyraModuleProtocol>(_ subscriber: AnyObject, for module: M.Type, use observer: M.Observer) {
        
        let mIdentifier = M.identify
        let sIdentifier = SubscriberIdentifier(subscriber)
        observer.moduleIdentify = mIdentifier
        observer.subscriberIdentifier = sIdentifier
        let subscription = Subscription(subscriber: subscriber, observer: observer)

        /// Update the subscriptions (aka. dictionary)
        if Lyra.contains(module: mIdentifier) {
            Lyra.G.subscriptions[mIdentifier]![sIdentifier] = subscription
        } else {
            Lyra.G.subscriptions[mIdentifier] = [sIdentifier: subscription]
        }
        let store = addAStoreIfNeed(M.self) as! Store<M.Observer.StoreSubscriberStateType>
        store.subscribe(observer)
    }
    
    /// unsubscribe a subscription of the `module` that satisfies
    /// the given subscriber.
    ///
    /// - Parameters:
    ///   - subscriber: the given  subscriber
    ///   - module: the given module
    func unsubscribe<M: LyraModuleProtocol>(_ subscriber: AnyObject, for module: M.Type) {
        Lyra.G.removeSubscription(SubscriberIdentifier(subscriber), for: M.self)
    }
    
    /// Add a `Store` (`ReSwift`) to the dictionary,
    /// then return the `Store`
    ///
    /// - Parameter module: the given module
    /// - Returns: `Store<M.StateType>`
    @discardableResult
    private func addAStoreIfNeed<M: LyraModuleProtocol>(_ module: M.Type) -> Store<M.StateType> {
        if let store = StoreStore[M.identify]  {
            return store as! Store<M.StateType>
        }
        /// For this moment, the `state` in the init for `Store` always `nil`
        /// Is it necessity to make it cu
        /// stomizable?
        /// Tell me if you have some issues about it (E-Mail: `mayerdev01@gmail.com`)
        StoreStore[M.identify] = Store<M.StateType>(reducer: M.reducer(_:_:), state: nil)
        return StoreStore[M.identify] as! Store<M.StateType>
    }
    
    /// force remove a subscription of the `module` that satisfies
    /// the given subscriberIdentifier which indicating a subscriber.
    ///
    /// - Parameters:
    ///   - subscriberIdentifier: ObjectIdentifier of the subscriber
    ///   - module: the given module
    func removeSubscription<M: LyraModuleProtocol>(_ subscriberIdentifier: SubscriberIdentifier, for module: M.Type) {
        removeSubscription(subscriberIdentifier, for: M.identify, with: M.StateType.self)
    }
    
    /// force remove a subscription of the `identify` that satisfies
    /// the given subscriberIdentifier which indicating a subscriber.
    ///
    /// - Parameters:
    ///   - subscriberIdentifier: ObjectIdentifier of the subscriber
    ///   - identify: the given identify
    ///   - stateType: stateType
    func removeSubscription<S>(_ subscriberIdentifier: SubscriberIdentifier, for identify: LyraModuleIdentify, with stateType: S.Type) {
        if let shouldRemove = subscriptions[identify]?.removeValue(forKey: subscriberIdentifier) {
            /// unsubscribe a Store from the ReSwift
            if let observer = shouldRemove.observer {
                store(of: identify, with: S.self)?.unsubscribe(observer as! AnyStoreSubscriber)
            }
        }
        cleanSubscription(for: identify)
    }
    
    /// force remove a subscription of the `module`
    /// - Parameter module: the given module
    func removeSubscription<M: LyraModuleProtocol>(for module: M.Type) {
        removeSubscription(for: M.identify)
    }
    
    /// force remove a subscription of the `identify`
    /// - Parameter identify: the given identify
    func removeSubscription(for identify: LyraModuleIdentify) {
        subscriptions.removeValue(forKey: identify)
        StoreStore.removeValue(forKey: identify)
    }
    
    /// clean the subscription
    /// - Parameter identify: identify of module
    func cleanSubscription(for identify: LyraModuleIdentify) {
        if subscriptions[identify]?.isEmpty ?? true {
            /// If the `subscriptions` doesn't contain the `module` anymore
            /// then clear the `subscriptions` and `StoreStore`
            removeSubscription(for: identify)
        }
    }
    
    /// Return a observer(`M.Observer`) that satisfies the given module(`M`)
    /// and `subscriber`
    /// - Parameters:
    ///   - module: the given module
    ///   - subscriber: the given  subscriber
    /// - Returns:  `true` if the `subscriptions` contains an element that satisfies
    ///   `moduel` and `subscriber`; otherwise, `false`.
    func observer<M: LyraModuleProtocol>(of module: M.Type, for subscriber: AnyObject) -> M.Observer? {
        subscriptions[M.identify]?[SubscriberIdentifier(subscriber)]?.observer as? M.Observer
    }
    
    /// Return a store of the given module(`M`)
    /// - Parameter module: the given module
    /// - Returns: the `Store` of the given module
    func store<M: LyraModuleProtocol>(of module: M.Type) -> Store<M.StateType> {
        guard let store = store(of: M.identify, with: M.StateType.self) else {
            return addAStoreIfNeed(M.self)
        }
        return store
    }
    
    func store<S>(of identify: LyraModuleIdentify, with stateType: S.Type) -> Store<S>? {
         StoreStore[identify] as? Store<S>
    }
}


/// TODO: Comment
public class LyraDispatcher<M: LyraModule> {
    
    /// An convenience way to call actions from module like that:
    /// ```
    ///     Lyra.module(\.search).action { actions in
    ///         actions.placeholder("Hello world!")
    ///     }
    ///
    /// ```
    /// - Parameter closure:
    public static func action(_ closure: (M.Actions.Type) -> Action ) {
        Lyra.G
            .store(of: M.self)
            .dispatch(closure(M.Actions.self))
    }
    
    /// Return the `Observer` if the `subscription` that satisfies the
    /// given `subscriber` exist.
    ///
    /// - Parameter subscriber: the given subscriber
    /// - Returns: Observer
    public static func observe(_ subscriber: AnyObject) -> M.Observer?  {
        guard Lyra.contains(module: M.self, of: subscriber) else {
            return nil
        }
        return Lyra.G.observer(of: M.self, for: subscriber)
    }
    
    /// Return an `observer` instance from the module (`M`) of subscription that `subscriber` subscribe.
    ///
    /// - Parameter subscriber: the given subscriber
    /// - Returns: Return the `observer` that only belong the `subscriber`
    @discardableResult
    public static func subscribe(_ subscriber: AnyObject) -> ObserverBox<M> {
        if !Lyra.contains(module: M.self, of: subscriber) {
            subscribeNewModule(subscriber)
        }
        return .init(subscriber: subscriber)
    }
    
    /// Unsubscibe the module(`M`) from `subscriber`
    ///
    /// - Parameter subscriber: AnyObject
    public static func unsubscribe(_ subscriber: AnyObject) {
        Lyra.G.unsubscribe(subscriber, for: M.self)
    }
    
    private static func subscribeNewModule(_ subscriber: AnyObject) {
        let observer = M.Observer()
        Lyra.G.subscribe(subscriber, for: M.self, use: observer)
        observer.subscriber = subscriber
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
    
    public static func sub<SUB: LyraModule>(_ keyPath: KeyPath<M.submodule, SUB.Type>) -> LyraDispatcher<SUB>.Type {
        return LyraDispatcher<SUB>.self
    }
}

public class ObserverBox<M: LyraModuleProtocol> {
    weak var subscriber: AnyObject?
    public var observer: M.Observer? {
        guard let _ = subscriber else {
            return nil
        }
        return Lyra.G.observer(of: M.self, for: subscriber!)
    }
    init(subscriber: AnyObject?) {
        self.subscriber = subscriber
    }
}
