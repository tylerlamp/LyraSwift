# Lyra

Hi, Everyone! I am so excited be here to telling you guys about the project. Make a long story short, The **LyraSwift** is an abstract layer above [ReSwift](https://github.com/ReSwift/ReSwift) that trans your **Store/State** to a module.

## Compare
> **Dispatch Action**

**ReSwift** :
```Swift
/// Auth module
Store<AuthState>.dispatch(AuthAction(isLogin: true))

/// search module
Store<SearchState>.dispatch(SearchKeywordAction(text: "Hello world"))
```
**LyraSwift** :
```Swift
/// Auth module
Lyra.module(\.auth).dispatch {
    $0.login(true)
}

/// search module
Lyra.module(\.search).dispatch {
    $0.keyword(text: "Hello world")
}
```

> **obtain latest state**

**ReSwift** :
```Swift
/// Auth module
let state = Store<AuthState>.state

/// search module
let state = Store<SearchState>.state
```
**LyraSwift** :
```Swift
/// Auth module
Lyra.module(\.auth).current { newState in
    /// some code
}

/// serch module
Lyra.module(\.search).current { newState in
    /// some code
}
```

> **observe state**


**ReSwift** :
```Swift
/// Auth module
class SomePage: StoreSubscriber {
    init() {
        Store<AuthState>.subscribe(self)
    }
  
   func newState(state: AuthState) {
        /// some code
   }
}
```
**LyraSwift** :
```Swift

class SomePage {
    init() {
        /// Auth module
        Lyra.module(\.auth).subscribe(self)
    }
    
    /// Then observe new state any where
    func someFunction() {
      
      Lyra.module(\.auth).observe.onLogin { isLogin in
          /// some code
      }
      
      /// And you can subscribe multimodule in the same object
      Lyra.module(\.search).observe.onKeyword { keyword in
          /// some code
      }
    }
}

```


