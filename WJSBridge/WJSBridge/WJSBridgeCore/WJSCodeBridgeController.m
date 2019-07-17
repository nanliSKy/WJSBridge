//
//  WJSCodeBridgeController.m
//  WJSBridge
//
//  Created by nanli on 2019/7/6.
//  Copyright © 2019 nanli. All rights reserved.
//

#import "WJSCodeBridgeController.h"

#import "WJSBridge.h"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wdeprecated-implementations"

@interface WJSCodeBridgeController ()<UIWebViewDelegate>
@property (strong, nonatomic) UIWebView *webView;
/** */
@property (nonatomic, strong) WJSBridge *jsBridge;
/** */
@property (nonatomic, strong) UILabel *interMsg;
@end

@implementation WJSCodeBridgeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 500)];
    //    _webView.delegate = self;
    [self.view addSubview:_webView];
    // 注入JSBridge代码
    self.jsBridge = [WJSBridge regist:_webView target:self];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"JSCoreExample" ofType:@"html"] ]];
    [_webView loadRequest:request];
    
//    UIButton *callback = [[UIButton alloc] initWithFrame:CGRectMake(20, 550, 100, 40)];
//    callback.backgroundColor = [UIColor redColor];
//    callback.layer.cornerRadius = 8;
//    [callback setTitle:@"回调 JS" forState:UIControlStateNormal];
//    [callback setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [callback addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:callback];
    
    UIButton * jsCall = [[UIButton alloc] initWithFrame:CGRectMake(140, 550, 100, 40)];
    jsCall.backgroundColor = [UIColor redColor];
    jsCall.layer.cornerRadius = 8;
    [jsCall setTitle:@"调用 JS" forState:UIControlStateNormal];
    [jsCall setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [jsCall addTarget:self action:@selector(jSCallClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:jsCall];
    
    UILabel *interMsg = [[UILabel alloc] initWithFrame:CGRectMake(20, 600, CGRectGetWidth(self.view.frame)-40, 200)];
    interMsg.numberOfLines = 0;
    [self.view addSubview:interMsg];
    self.interMsg = interMsg;
}

#pragma mark native call method of js
- (void)buttonClick {
    
}

- (void)jSCallClick {
    [self.jsBridge executJs:@"nativeCall" param:@[@"a little word native", @[@"china!"]]];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://m.bcbchain.io/down"]];
}


#pragma mark js call method of native
- (void)callNativeFunction {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.interMsg.text = @"JS 调用 Native 成功";
    });
    
}


- (void)share:(NSDictionary *)param {
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:&parseError];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.interMsg.text = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    });
    
}

- (void)login:(NSDictionary *)param  {
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:&parseError];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.interMsg.text = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    });
    [self.jsBridge executCallBack:@[@"a little word"]];
}
#pragma clang diagnostic pop
@end
