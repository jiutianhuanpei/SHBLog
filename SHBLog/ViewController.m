//
//  ViewController.m
//  SHBLog
//
//  Created by shenhongbang on 16/8/4.
//  Copyright © 2016年 沈红榜. All rights reserved.
//

#import "ViewController.h"
#import "SHBLog.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = UIColor.redColor;
    
    HBSetOutputLevel(HBLogOutputLevel_Error | HBLogOutputLevel_Warning | HBLogOutputLevel_Writen);
    
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject;
    
    NSString *path = [document stringByAppendingString:@"20210624.log"];
    HBSetLogPath(path);
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [btn addTarget:self action:@selector(didClickedBtn) forControlEvents:UIControlEventTouchUpInside];
    btn.center = self.view.center;
    [self.view addSubview:btn];
    
    
}


- (void)didClickedBtn {
    
    HBLog(@"%s", __FUNCTION__);
    HBWarnLog(@"%s", __FUNCTION__);
    HBErrorLog(@"%s", __FUNCTION__);
    HBFatal(@"%s", __FUNCTION__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
