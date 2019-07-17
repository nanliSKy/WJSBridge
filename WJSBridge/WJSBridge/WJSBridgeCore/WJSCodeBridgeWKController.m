//
//  WJSCodeBridgeWKController.m
//  WJSBridge
//
//  Created by nanli on 2019/7/8.
//  Copyright © 2019 nanli. All rights reserved.
//

#import "WJSCodeBridgeWKController.h"
#import <WebKit/WebKit.h>

#import "WJSBridgeHandler.h"

@interface WJSCodeBridgeWKController ()
/** */
@property (weak, nonatomic) IBOutlet UIView *webContainer;
/** */
@property (weak, nonatomic) IBOutlet UIButton *nativeBtn;
/** */
@property (weak, nonatomic) IBOutlet UILabel *interMsg;
/** */
@property (nonatomic, strong) WKWebView *webView;
/** */
@property (nonatomic, strong) WJSBridgeHandler *bridgeHandler;

@end

@implementation WJSCodeBridgeWKController

+ (instancetype)wkController {
  return   [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:[WJSCodeBridgeWKController description]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"WJSBridgeHandler";
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    self.bridgeHandler = [WJSBridgeHandler regist:configuration target:self];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)/2.0) configuration:configuration];
    [self.webContainer addSubview:self.webView];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"WJSWKCodeExample" ofType:@"html"] ]];
    self.bridgeHandler.webView = self.webView;
    [self.webView loadRequest:request];
     
}


- (IBAction)callJavaScriptMethod:(UIButton *)sender {
    [self.bridgeHandler executJs:@"nativeCall" params:@"native call JS success" completed:^(id  _Nonnull data, NSError * _Nonnull error) {
        
    }];
}


#pragma mark JS 调用

- (void)callNativeFunction {
    self.interMsg.text = @"JS 调用 Native 成功";
}


- (void)share:(NSDictionary *)param {
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:&parseError];
    
    self.interMsg.text = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (void)login:(NSDictionary *)param :(walletCallBlock)callBlock {
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:&parseError];
    
    self.interMsg.text = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    callBlock(@"callBack success");
}



@end
