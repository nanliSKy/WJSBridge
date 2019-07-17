# WJSBridge
 方便 Javascript 与 OC 之前相互调用、传值、回调。
# JavaScript 与 iOS 交互

## iOS 使用 UIWebview 加载 H5

### JavaScript调用 iOS 方法

```javascript
walletBridge(method, params, callBack)
```

举例说明:JavaScript 调用objective-C(OC)方法

1.普通方法

```javascript
walletBridge('download')
```

OC实现方法	

```objective-c
-(void)download{}
```

2.带参数方法

```javascript
walletBridge('share', {
    title:'title',
    context: 'context',
    url: 'url'
})
```

OC实现方法

```objective-c
- (void)share:(NSDictionary *)param {}
```

3.带参数及回调函数

```javascript
walletBridge("login", {
        userName:'nanli',
        password:'qwe'
        }, function(data){
             console.log('login success:'+ data);
      })
```

OC 实现方法

```objective-c
- (void)login:(NSDictionary *)param {}
```

回调函数

```objective-c
[self.jsBridge executCallBack:@[@"a little word"]];
```

### OC 调用 JavaScript 方法

```objective-c
- (void)executJs:(NSString *)method param:(NSArray *)param;
```



## iOS使用 WKWebView 加载H5

### JavaScript 调用 iOS方法

```javascript
WJSBridge.walletCall(method, param, callBack)
```

1.普通方法

```javascript
WJSBridge.walletCall('download');
```

OC 实现方法

```objective-c
-(void)download{}
```

2.带参数的方法

```javascript
WJSBridge.walletCall('share', {
    title:'title',
    context: 'context',
    url: 'url'
})
```



OC 实现方法

```objective-c
- (void)share:(NSDictionary *)param {}
```

3.带参数及回调函数

```javascript
WJSBridge.walletCall("login", {
        userName:'nanli',
        password:'qwe'
        }, function(data){
             console.log('login success:'+ data);
      })
```

OC 实现方法

```objective-c
- (void)login:(NSDictionary *)param :(walletCallBlock)callBlock;
```

### OC 调用 JavaScript方法

```objective-c
- (void)executJs:(NSString *)method params:(NSString *)params completed:(void(^)(id data, NSError *error))completed;
```



## 核心类

### WJSBridge

```objective-c
@interface WJSBridge : NSObject

+(instancetype)regist:(UIWebView *)webView target:(NSObject *)target;

/**
 native 主动调用 JS

 @param method  JS 方法
 @param param native 传给 JS 参数
 */
- (void)executJs:(NSString *)method param:(NSArray *)param;

/**
 回调, native 调用 JS

 @param param native 传给 JS 参数
 */
- (void)executCallBack:(NSArray *)param;

@end
```

### WJSBridgeHandler

```objective-c
typedef void(^walletCallBlock) (id response);

@interface WJSBridgeHandler : NSObject<WKScriptMessageHandler>
/** */
@property (nonatomic, strong) WKWebView *webView;

+ (instancetype)regist:(WKWebViewConfiguration *)config target:(NSObject *)target;

/**
 native 调用 JS 方法

 @param method JS响应的方法名
 @param params  JS接收参数
 @param completed 返回结果
 */
- (void)executJs:(NSString *)method params:(NSString *)params completed:(void(^)(id data, NSError *error))completed;;
@end
```



### WJSBridge.js

```javascript
var WJSBridge = {
    walletCall: function(method, params, callBack) {
        var message;
        if (!callBack) {
            message = {'method': method, 'params': params};
            window.webkit.messageHandlers.WJSBridge.postMessage(message);
        }else {
            var callBackId = method+'callBack';
            message = {'method': method, 'params': params, 'callBack': callBackId};
            if (!WJSBridgeEvent._listeners[callBackId]) {
                WJSBridgeEvent.addEvent(callBackId, function (data){
                    callBack(data);
                })
            }
            window.webkit.messageHandlers.WJSBridge.postMessage(message);
        }
    },
    
    walletCallBack: function (callBackId, data) {
        WJSBridgeEvent.fireEvent(callBackId, data);
    }
};

var WJSBridgeEvent = {
    _listeners:{},

    addEvent: function(type, fn) {
        if (typeof this._listeners[type] === "undefined") {
            this._listeners[type] = [];
        }
        if (typeof fn === "function") {
            this._listeners[type].push(fn);
        }
        return this;
    },

    fireEvent: function (type, params) {
        var arrayEvent = this._listeners[type];
        if (arrayEvent instanceof Array) {
            for (var i = 0, len = arrayEvent.length; i<len; i+=1) {
                if (typeof arrayEvent[i] === "function") {
                    arrayEvent[i](params);
                }
            }
        }
        return this;
    },

    removeEvent: function (type, fn) {
        var arrayEvent = this._listeners[type];
        if (typeof type === "string" && arrayEvent instanceof Array) {
            if (typeof fn === "function") {
                for (var i=0, length=arrayEvent.length; i<length; i+=1){
                    if (arrayEvent[i] === fn){
                        this._listeners[type].splice(i, 1);
                        break;
                    }
                }
            } else {
                delete this._listeners[type];
            }
        }
        
        return this;
    }

};

```

