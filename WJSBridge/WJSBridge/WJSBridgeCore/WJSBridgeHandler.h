//
//  WJSBridgeHandler.h
//  WJSBridge
//
//  Created by nanli on 2019/7/8.
//  Copyright © 2019 nanli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^walletCallBlock) (id response);

@interface WJSBridgeHandler : NSObject<WKScriptMessageHandler>
/** */
@property (nonatomic, strong) WKWebView *webView;


+ (instancetype)regist:(WKWebViewConfiguration *)config target:(NSObject *)target;


+ (void)clearHandler:(WJSBridgeHandler *)handler;

/**
 native 调用 JS 方法

 @param method JS响应的方法名
 @param params  JS接收参数
 @param completed 返回结果
 */
- (void)executJs:(NSString *)method params:(NSString *)params completed:(void(^)(id data, NSError *error))completed;
@end

NS_ASSUME_NONNULL_END
