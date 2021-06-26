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

//TODO: comment
public protocol LyraModule {
    
    associatedtype StateType
    //TODO: comment
    associatedtype Actions: LyraAction
    //TODO: comment
    associatedtype Observer: LyraObserverSubscriber
    // TODO: comment
    static func reducer(_ action: Action, _ state: StateType?) -> StateType
}

extension LyraModule {
    
    static var identify: LyraModuleIdentify {
        String(describing: Self.self)
    }
}



