//
//  LyraObserver.swift
//  LyraSwift
//
//  Created by Tyler@work on 2021/6/26.
//  Copyright © 2021 LyraSwift. All rights reserved.
//

import ReSwift

open class LyraObserver {
    weak var subscriber: AnyObject?
    static var identify: String {
        String(describing: Self.self)
    }
    required public init() {}
    
    open func ReSubscribe() {
        fatalError("请在子类中重写这个方法")
    }
    
    open func ReUnsubscribe() {
        fatalError("请在子类中重写这个方法")
    }
}

