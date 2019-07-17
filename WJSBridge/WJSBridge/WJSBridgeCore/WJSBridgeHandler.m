//
//  WJSBridgeHandler.m
//  WJSBridge
//
//  Created by nanli on 2019/7/8.
//  Copyright © 2019 nanli. All rights reserved.
//

#import "WJSBridgeHandler.h"
static NSString * const WJSBridge = @"WJSBridge";

@interface WJSBridgeHandlerEmpty :NSObject

@end

@implementation WJSBridgeHandlerEmpty

@end

@interface WJSBridgeHandler ()
/** */
@property (nonatomic, strong) NSObject *target;
@end
@implementation WJSBridgeHandler

+ (instancetype)regist:(WKWebViewConfiguration *)config target:(NSObject *)target{
    WJSBridgeHandler *bridgeHandler = [WJSBridgeHandler new];
    bridgeHandler.target = target;
    
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:[bridgeHandler prepareHandlerJS] injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    config.userContentController = [[WKUserContentController alloc] init];
    [config.userContentController addUserScript:userScript];
    [config.userContentController addScriptMessageHandler:bridgeHandler  name:WJSBridge];
    return bridgeHandler;
}

+ (void)clearHandler:(WJSBridgeHandler *)handler {
    if (handler.webView) {
        [handler.webView evaluateJavaScript:@"WJSBridge.removeAllCallBacks();" completionHandler:nil];//删除所有的回调事件
        [handler.webView.configuration.userContentController removeScriptMessageHandlerForName:WJSBridge];
    }
    handler = nil;
}


- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:WJSBridge]) {
        NSString *method = message.body[@"method"];
        NSString *callBack = message.body[@"callBack"];
        NSDictionary *params = message.body[@"params"];
        __weak typeof(self) wSelf = self;
        
        if (callBack) {
            [self interactMethod:method params:params complation:^(id response) {
                if (callBack && callBack.length) {
                    [wSelf executCallBack:callBack response:response];
                }
            }];
        }else {
            [self interactMethod:method params:params complation:nil];
        }
        
    }
}

- (void)interactMethod:(NSString *)method params:(NSDictionary *)params complation:(void(^)(id response))callBack {
    NSMutableArray *paramsArr = [NSMutableArray array];
    if (params) {
        method = [NSString stringWithFormat:@"%@:", method];
        [paramsArr addObject:params];
    }
    if (callBack) {
        method = [NSString stringWithFormat:@"%@:", method];
        [paramsArr addObject:callBack];
    }
    SEL selector = NSSelectorFromString(method);
    if ([self.target respondsToSelector:selector]) {
        NSMethodSignature *methodSignature = [[self.target class] instanceMethodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setTarget:self.target];
        [invocation setSelector:selector];
        
        NSUInteger i = 1;
        for (id object in paramsArr) {
            id tempObject = object;
            if (![tempObject isKindOfClass:[NSObject class]]) {
                if ([tempObject isSubclassOfClass:[WJSBridgeHandlerEmpty class]]) {
                    tempObject = nil;
                }
            }
            [invocation setArgument:&tempObject atIndex:++i];
        }
        [invocation invoke];
        
        if ([methodSignature methodReturnLength]) {
            id data;
            [invocation getReturnValue:&data];
            
        }
    }
   
}

- (void)executCallBack:(NSString *)callBack response:(id)response {
    __weak  WKWebView *weakWebView = _webView;
    if ([response isKindOfClass:[NSDictionary class]] || [response isKindOfClass:[NSMutableDictionary class]] || [response isKindOfClass:[NSArray class]] || [response isKindOfClass:[NSMutableArray class]]) {
        NSData *data=[NSJSONSerialization dataWithJSONObject:response options:NSJSONWritingPrettyPrinted error:nil];
        
        NSString *jsonStr=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        response = jsonStr;
    }
    NSString *js = [NSString stringWithFormat:@"WJSBridge.walletCallBack('%@','%@');",callBack,response];
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakWebView evaluateJavaScript:js completionHandler:^(id _Nullable data, NSError * _Nullable error) {
            
        }];
    });
}

- (void)executJs:(NSString *)method params:(NSString *)params completed:(void (^)(id _Nonnull, NSError * _Nonnull))completed {
    NSString *javaScript = [NSString stringWithFormat:@"%@('%@')", method, params];
    [self.webView evaluateJavaScript:javaScript completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        if (completed) {
            completed(data, error);
        }
    }];
}
- (NSString *)prepareHandlerJS {
    NSString *path =[[NSBundle bundleForClass:[self class]] pathForResource:@"WJSBridge" ofType:@"js"];
    NSString *handlerJS = [NSString stringWithContentsOfFile:path encoding:kCFStringEncodingUTF8 error:nil];
    handlerJS = [handlerJS stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return handlerJS;
}
@end
