//
//  ViewController.m
//  WJSBridge
//
//  Created by nanli on 2019/7/6.
//  Copyright © 2019 nanli. All rights reserved.
//

#import "ViewController.h"
#import "WJSBridgeCore/WJSCodeBridgeWKController.h"
@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *demoListView;
@property (strong, nonatomic) NSArray *titles;
@property (strong, nonatomic) NSArray *controllers;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.demoListView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_demoListView];
    _demoListView.delegate = self;
    _demoListView.dataSource = self;
    self.title = @"JSBridgeDemo";
    //    self.titles = @[@"AjaxBridge", @"IframeBridge", @"JSCoreBridge"];
    //    self.controllers = @[@"CRAjaxBridgeController", @"CRIframeBridgeController", @"CRJSCoreBridgeController"];
    self.titles = @[@"WJSBridge", @"WJSBridgeHandler"];
    self.controllers = @[@"WJSCodeBridgeController", @"WJSCodeBridgeWKController"];
    // Do any additional setup after loading the view.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] init];
    }
    cell.textLabel.text = _titles[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row==0) {
        NSString *controllerClassName = _controllers[indexPath.row];
        Class class = NSClassFromString(controllerClassName);
        UIViewController *vc = [[class alloc] init];
        vc.title = _titles[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        [self.navigationController pushViewController:[WJSCodeBridgeWKController wkController] animated:YES];
    }
    
}


@end
