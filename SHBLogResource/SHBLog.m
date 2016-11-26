//
//  SHBLog.m
//  SHBLog
//
//  Created by shenhongbang on 2016/11/26.
//  Copyright © 2016年 中移(杭州)信息技术有限公司. All rights reserved.
//

#import "SHBLog.h"

//获取当前进程号
#import <pthread.h>

//打印所需
#import <sys/uio.h>


void MyLog(NSString *msg) {
    
    
    NSUInteger length = [msg lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    
    char *msgChar = malloc(length + 1);
    
    [msg getCString:msgChar maxLength:length + 1 encoding:NSUTF8StringEncoding];
    
    int count = 2;
    
    struct iovec iove[count];

    iove[0].iov_base = (char *)msgChar;
    iove[0].iov_len = length + 1;
    
    iove[1].iov_base = "\n";
    iove[1].iov_len = (msgChar[1] == '\n') ? 0 : 1;
    
    writev(STDOUT_FILENO, iove, count);
}


void SHBPrint(NSString *mat, ...) {
    va_list args;
    va_start(args, mat);
    NSString *msg = [[NSString alloc] initWithFormat:mat arguments:args];
    va_end(args);
    MyLog(msg);
}

void SHBLog(NSString *mat, ...) {
    va_list args;
    va_start(args, mat);
    NSString *msg = [[NSString alloc] initWithFormat:mat arguments:args];
    va_end(args);
    
    /**
     *  系统前缀
     */
    static NSDateFormatter *df = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    });
    
    NSString *time = [NSString stringWithFormat:@"%@", [df stringFromDate:[NSDate date]]];
    
    
    NSString *appName = [[NSProcessInfo processInfo] processName];
    NSString *processID = [NSString stringWithFormat:@"%i", (int)getpid()];
    NSString *thirdId = nil;
    
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
        __uint64_t tid;
        pthread_threadid_np(NULL, &tid);
        thirdId = [[NSString alloc] initWithFormat:@"%llu", tid];
    }
    else
    {
        thirdId = [[NSString alloc] initWithFormat:@"%x", pthread_mach_thread_np(pthread_self())];
    }
    
    time = [NSString stringWithFormat:@"%@ %@[%@:%@] ", time, appName, processID, thirdId];
    
    
    msg = [time stringByAppendingString:msg];   //添加系统前缀
    
    
    MyLog(msg);
}

