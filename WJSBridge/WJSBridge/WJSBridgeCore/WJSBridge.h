//
//  WJSBridge.h
//  CRJsBridgeDemo
//
//  Created by nanli on 2019/7/5.
//  Copyright © 2019 crmo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN


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

NS_ASSUME_NONNULL_END
