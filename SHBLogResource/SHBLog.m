//
//  SHBLog.m
//  SHBLog
//
//  Created by shenhongbang on 2016/11/26.
//  Copyright © 2016年 沈红榜. All rights reserved.
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


@interface SHBLog : NSObject

@property (nonatomic, assign) HBLogOutputLevel showLevel;
@property (nonatomic, copy) NSString *logPath;
@property (nonatomic, strong) NSFileHandle *fileHandle;

@end

@implementation SHBLog

+ (instancetype)shareInstance {
    static SHBLog *log = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        log = SHBLog.new;
        log.showLevel = HBLogOutputLevel_All;
    });
    return log;
}

+ (void)setOutpuLevel:(HBLogOutputLevel)showLevel {
    [SHBLog shareInstance].showLevel = showLevel;
}

+ (void)setLogPath:(NSString *)logPath {
    [SHBLog shareInstance].logPath = logPath;
}

+ (void)log:(HBLogLevel)level msg:(NSString *)mat, ... {
    
    BOOL canPrint = [self canLog:level];
    if (!canPrint) {
        return;
    }
    
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
    
    NSString *prefix = [NSString stringWithFormat:@"%@ %@[%@:%@] ", time, appName, processID, thirdId];
    
    prefix = [prefix stringByAppendingString:[self strFrom:level]];
    
    NSString *output = [prefix stringByAppendingString:msg];
    
    if ([SHBLog shareInstance].showLevel & HBLogOutputLevel_Writen) {
        [[SHBLog shareInstance].fileHandle writeData:[[output stringByAppendingString:@"\n"]  dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    MyLog(output);
}


#pragma mark - helps
+ (NSString *)strFrom:(HBLogLevel)level {
    switch (level) {
        case HBLogLevel_Error:
            return @"Error: ";
        case HBLogLevel_Warning:
            return @"Warning: ";
        case HBLogLevel_Fatal:
            return @"Fatal: ";
        default:
            break;
    }
    return @"";
}

+ (BOOL)canLog:(HBLogLevel)level {
    
    HBLogOutputLevel showLevel = [SHBLog shareInstance].showLevel;
    if (showLevel == HBLogOutputLevel_All) {
        return true;
    }
    
    switch (level) {
        case HBLogLevel_Normal:
            return showLevel & HBLogOutputLevel_Normal;
        case HBLogLevel_Warning:
            return showLevel & HBLogOutputLevel_Warning;
        case HBLogLevel_Error:
            return showLevel & HBLogOutputLevel_Error;
        case HBLogLevel_Fatal:
            return showLevel & HBLogOutputLevel_Fatal;
        default:
            break;
    }
    return false;
}

- (void)setLogPath:(NSString *)logPath {
    _logPath = logPath;
    
    NSFileManager *manager = NSFileManager.defaultManager;
    
    if (![manager fileExistsAtPath:logPath]) {
        [manager createFileAtPath:logPath contents:nil attributes:nil];
    }
    SHBPrint(@"App log file at: %@", logPath);
    
    _fileHandle = [NSFileHandle fileHandleForWritingAtPath:logPath];
}

@end



void HBSetOutputLevel(HBLogOutputLevel level) {
    
    [SHBLog setOutpuLevel:level];
}

void HBSetLogPath(NSString *logPath) {
    [SHBLog setLogPath:logPath];
}

void HBLog(NSString *mat, ...) {
    
    va_list args;
    va_start(args, mat);
    NSString *msg = [[NSString alloc] initWithFormat:mat arguments:args];
    va_end(args);
    
    [SHBLog log:HBLogLevel_Normal msg:msg];
}

void HBWarnLog(NSString *mat, ...) {
    
    va_list args;
    va_start(args, mat);
    NSString *msg = [[NSString alloc] initWithFormat:mat arguments:args];
    va_end(args);
    
    [SHBLog log:HBLogLevel_Warning msg:msg];
}

void HBErrorLog(NSString *mat, ...) {
    
    va_list args;
    va_start(args, mat);
    NSString *msg = [[NSString alloc] initWithFormat:mat arguments:args];
    va_end(args);
    
    [SHBLog log:HBLogLevel_Error msg:msg];
}

void HBFatal(NSString *mat, ...) {
    
    va_list args;
    va_start(args, mat);
    NSString *msg = [[NSString alloc] initWithFormat:mat arguments:args];
    va_end(args);
    
    [SHBLog log:HBLogLevel_Fatal msg:msg];
}

