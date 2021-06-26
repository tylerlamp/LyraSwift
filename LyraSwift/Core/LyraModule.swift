//
//  LyraModule.swift
//  LyraSwift
//
//  Created by Tyler@work on 2021/6/26.
//  Copyright © 2021 LyraSwift. All rights reserved.
//

import Foundation

public typealias LyraModuleIdentify = String

//TODO: comment
public protocol LyraModule {
    //TODO: comment
    associatedtype Action: LyraAction
    //TODO: comment
    associatedtype Observer: LyraObserver
}

extension LyraModule {
    
    static var identify: LyraModuleIdentify {
        String(describing: Self.self)
    }
}



