//
//  LyraAction.swift
//  LyraSwift
//
//  Created by Tyler@work on 2021/6/26.
//  Copyright © 2021 LyraSwift. All rights reserved.
//

import ReSwift

/// As a abstract layer above `ReSwift` we need to implement the `Action` anyway.
/// For the intergration, you should use `LyraAction` instead while
/// you building your `Store` with `Lyra`.
///
/// And there are some advises:
/// Always use `enum` type to implement `LyraAction`(aka. `Action`) as the main `Action`
/// In the most case of `Action`, `enum` is powerful enough. like:
///
/// ```
/// enum SomActionEnum: LyraAction {
///     case action1
///     case action2(p1: String)
///     ...
/// }
/// ```
/// Sometime you may want the `Action` be a `struct`, you can do that like this:
///
/// ```
/// extension SomActionEnum {
///     struct SomeActionStruct: LyraAction {
///
///     }
/// }
/// ```
///
/// make it be the `subAction` of main `Action` will trun your code
/// and logic more clearly.
///
///
///
public protocol LyraAction: Action {}
