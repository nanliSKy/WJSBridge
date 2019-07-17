//
//  WJSBridge.m
//  CRJsBridgeDemo
//
//  Created by nanli on 2019/7/5.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "WJSBridge.h"

#import <JavaScriptCore/JavaScriptCore.h>
typedef void(^walletCallBlock) (JSValue *param);
@interface WJSBridge ()
/** */
@property (nonatomic, strong) UIWebView *webView;
/** */
@property (nonatomic, strong) JSValue *functionValue;

@end

@implementation WJSBridge

+ (instancetype)regist:(UIWebView *)webView target:(NSObject *)target {
    WJSBridge *jsBrideg = [WJSBridge new];
    jsBrideg.webView = webView;
    __weak typeof(WJSBridge *) wJS = jsBrideg;
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    context[@"walletBridge"] = ^(JSValue *action, JSValue *data, JSValue *callBack) {
        NSString *actionStr = [action toString];
        NSDictionary *dataParam = [data toDictionary];
        if (dataParam) {
            actionStr = [NSString stringWithFormat:@"%@:", actionStr];
        }
        walletCallBlock callBlock = [callBack toObject];
        
        SEL selector = NSSelectorFromString(actionStr);
        NSMethodSignature *methodSignature = [[target class] instanceMethodSignatureForSelector:selector];
        
        if ([target respondsToSelector:selector]) {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
            [invocation setTarget:target];
            [invocation setSelector:selector];
            //签名中方法参数的个数，内部包含了self和_cmd，所以参数从第3个开始
            if (dataParam) {
                [invocation setArgument:&dataParam atIndex:2];
            }
            [invocation invoke];
            
            //返回值处理
            id backObject = nil;
            if(methodSignature.methodReturnLength)
            {
                [invocation getReturnValue:&backObject];
            }
            NSLog(@"backObject= %@", backObject);
        }
//        @throw [NSException exceptionWithName:@"抛异常错误" reason:@"没有这个方法，或者方法名字错误" userInfo:nil];
        
        if (callBlock) {
            wJS.functionValue = callBack;
        }else {
            wJS.functionValue = nil;
        }
    };
    return jsBrideg;
}

- (void)executCallBack:(NSArray *)param {
    if (self.functionValue) {
        [self.functionValue callWithArguments:param];
    }
}

- (void)executJs:(NSString *)method param:(NSArray *)param {
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    JSValue *value = context[method];
    [value callWithArguments:param];
}


@end
