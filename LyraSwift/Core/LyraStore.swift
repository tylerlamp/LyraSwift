//
//  LyraStore.swift
//  LyraSwift
//
//  Created by Tyler@work on 2021/6/26.
//  Copyright © 2021 LyraSwift. All rights reserved.
//

import Foundation

/// When you finish your module building
/// you should register to the `LyraStore`, like that:
/// ```
///  extension LyraStore {
///     var someModule: SomeModule.type { SomeModule.self }
///  }
/// ```
/// you can write it in anywhere
///
/// then just easily to call it:
/// ```
///     Lyra.module(\.someModule)
/// ```
///
public struct LyraStore {}
