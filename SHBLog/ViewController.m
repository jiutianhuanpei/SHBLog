//
//  ViewController.m
//  SHBLog
//
//  Created by shenhongbang on 16/8/4.
//  Copyright © 2016年 中移(杭州)信息技术有限公司. All rights reserved.
//

#import "ViewController.h"
#import "LogManager.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [LogManager setLogLevel:SHBLogLevelAll];
//    [LogManager setLogLevel:SHBLogLevelWarning | SHBLogLevelError | SHBLogLevelInfo];
    
//    [LogManager setColor:[UIColor redColor] forType:SHBLogTypeInfo];
//    [LogManager setColor:[UIColor purpleColor] forType:SHBLogTypeWarning];
    [LogManager setColorEnabled:true];
    

    SHBLog(@"logPath:\n%@", [LogManager sharedInstance].currentLogPath);

    
    SHBInfoLog(@"This is Info");
    SHBErrorLog(@"This is Error");
    SHBWarnLog(@"This is warning");
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
