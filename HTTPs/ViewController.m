//
//  ViewController.m
//  HTTPs
//
//  Created by xino on 2016/12/21.
//  Copyright © 2016年 HFS. All rights reserved.
//

#import "ViewController.h"
#import "OneWayHTTPS.h"
#import "TwoWayHTTPS.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    /// 服务器要么单向要么双向验证
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
/*
    /// 单向验证HTTPS请求
    [OneWayHTTPS POST:@"" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
*/
    
    
    /// 双向验证HTTPS请求
    [TwoWayHTTPS POST:@"" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

@end
