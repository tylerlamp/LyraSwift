//
//  LyraModule.swift
//  LyraSwift
//
//  Created by Tyler@work on 2021/6/26.
//  Copyright © 2021 LyraSwift. All rights reserved.
//
import ReSwift

public typealias LyraModuleIdentify = String
public typealias LyraObserverSubscriber = LyraObserver & StoreSubscriber


/// When you've defined your `StateType`; `LyraAction`; `LyraObserver`
/// Now you can assemble them to be a `LyraModule`, like this easy way:
///
/// ```
///  enum SearchModule: LyraModule {
///    typealias StateType = SearchState
///    typealias Actions = SearchAction
///    typealias Observer = SearchObserver
///
///    static func reducer(_ action: Action, _ state: SearchState?) -> SearchState {
///         // put your code of ReSwift's reducer in it
///    }
///  }
/// ```
/// And then register the module to the `LyraStore`:
/// ```
///     extension LyraStore {
///         var search: SearchModule.Type { SearchModule.self }
///     }
/// ```
///
/// finaly, you can call the module anywhere like that:
///
/// ```
///     // subscibe
///     Lyra.module(\.search).subscribe(self)
///
///     // dispatch action
///     Lyra.module(\.search).action { actions in
///         actions.updateKeyword("Hello world!")
///     }
///
///     // observe state
///     Lyra.module(\.search)
///         .observe(self)
///         .keyword  { newKeyword in
///             print(newKeyword) // Hello world!
///         }
///
///     // unsubscibe (don't forget it)
///     Lyra.module(\.search).unsubscribe(self)
/// ```
///
public protocol LyraModuleProtocol {
    associatedtype StateType
    associatedtype Actions: LyraAction
    associatedtype Observer: LyraObserverSubscriber
    static func reducer(_ action: Action, _ state: StateType?) -> StateType
}

//MARK: - Identification
extension LyraModuleProtocol {
    static var identify: LyraModuleIdentify {
        String(describing: Self.self)
    }
}

open class LyraBaseModule {
    public enum submodule {}
}

public typealias LyraModule = LyraBaseModule & LyraModuleProtocol


