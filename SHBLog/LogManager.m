//
//  LogManager.m
//  Test
//
//  Created by shenhongbang on 16/8/4.
//  Copyright © 2016年 中移(杭州)信息技术有限公司. All rights reserved.
//

#import "LogManager.h"

#import <unistd.h>
#import <sys/uio.h>
#import <pthread.h>


NSString *SHBLogTypeString(SHBLogType type) {
    switch (type) {
        case SHBLogTypeNormal: {
            return @"SHBLogTypeNormal";
            break;
        }
        case SHBLogTypeInfo: {
            return @"SHBLogTypeInfo";
            break;
        }
        case SHBLogTypeWarning: {
            return @"SHBLogTypeWarning";
            break;
        }
        case SHBLogTypeError: {
            return @"SHBLogTypeError";
            break;
        }
        default:
            break;
    }
    return @"";
}
@interface LogManager ()

@property (nonatomic, assign) SHBLogLevel   level;

@property (nonatomic, strong) NSMutableDictionary   *colorDic;
@property (nonatomic, copy) NSString  *filePath;

@property (nonatomic, assign) BOOL  colorEnabled;

@end


/**
 *  日志文件有效期
 */
NSTimeInterval const LOGTIMEOUT = 60 * 60 * 24;


@implementation LogManager

+ (LogManager *)sharedInstance {
    static LogManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LogManager alloc] init];
        manager.level = SHBLogLevelAll;
        manager.colorDic = [NSMutableDictionary dictionaryWithCapacity:0];
        manager.colorEnabled = true;
        manager.filePath = [manager createLocalFile];
        
        [manager.colorDic setObject:[UIColor colorWithRed:0.4533 green:0.3531 blue:1.0 alpha:1.0] forKey:SHBLogTypeString(SHBLogTypeInfo)];
        [manager.colorDic setObject:[UIColor redColor] forKey:SHBLogTypeString(SHBLogTypeError)];
        [manager.colorDic setObject:[UIColor orangeColor] forKey:SHBLogTypeString(SHBLogTypeWarning)];
        
    });
    return manager;
}

+ (void)setLogLevel:(SHBLogLevel)level {
    [LogManager sharedInstance].level = level;
}

// 不同的 log type
+ (void)logType:(SHBLogType)type message:(NSString *)aMessage, ... {
    LogManager *manager = [LogManager sharedInstance];
    /**
     *  不同 type 的log 的前缀
     */
    NSString *prix = @"";
    switch (type) {
        case SHBLogTypeInfo: {
            prix = @"Info: ";
            break;
        }
        case SHBLogTypeWarning: {
            prix = @"Warning: ";
            break;
        }
        case SHBLogTypeError: {
            prix = @"Error: ";
            break;
        }
        default:
            break;
    }
    
    va_list args;
    va_start(args, aMessage);
    
    NSString *temp = [[NSString alloc] initWithFormat:aMessage arguments:args];
    va_end(args);
    
    NSString *message = [NSString stringWithFormat:@"%@%@", prix, temp];
    
    /**
     *  不同打印type的前缀
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
    
    
    message = [time stringByAppendingString:message];   //添加时间
    
    UIColor *color = manager.colorDic[SHBLogTypeString(type)];
    if (color == nil) {
        color = [UIColor blackColor];
    }
    if ([self canLog:type]) {
        // 在控制台输出
        [manager logMessage:message fontColor:color backgroundColor:nil];
    }
    
    [self writeLogToLocalFile:message];
}

+ (void)writeLogToLocalFile:(NSString *)log
{
    NSString *logFilePath = [LogManager sharedInstance].filePath;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:logFilePath])
    {
        [log writeToFile:logFilePath atomically:true encoding:NSUTF8StringEncoding error:nil];
    }
    else
    {
        NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
        [handle seekToEndOfFile];
        [handle writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [handle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
        [handle closeFile];
    }
}

/**
 *  创建日志文件
 *
 *  @return 文件路径
 */
- (NSString *)createLocalFile
{
    NSString *logPath = [self documentPath:@"Log"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *files = [fileManager contentsOfDirectoryAtPath:logPath error:nil];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init ];
    [df setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
    
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    
    [files enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj hasSuffix:@"log"]) {
            NSString *fileName = [[obj componentsSeparatedByString:@"."] firstObject];
            NSDate *createDate = [df dateFromString:fileName];
            NSTimeInterval createTime = [createDate timeIntervalSince1970];
            if (nowTime - createTime >= LOGTIMEOUT) {
                
                NSString *removePath = [logPath stringByAppendingPathComponent:obj];
                [fileManager removeItemAtPath:removePath error:nil];
            }
        }
    }];
    
    NSString *fileName = [df stringFromDate:[NSDate dateWithTimeIntervalSince1970:nowTime]];
    NSString *path = [[self documentPath:@"Log"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.log", fileName]];
    
    return path;
}

+ (BOOL)canLog:(SHBLogType)type {
    
    LogManager *manager = [LogManager sharedInstance];
    

    SHBLogLevel level = manager.level;
    
    if ((level & SHBLogLevelNone) != 0) {
        return false;
    }
    
    if ((level & SHBLogLevelAll) != 0) {
        return true;
    }
    
    if ((level & SHBLogLevelInfo) != 0) {
        if (type == SHBLogTypeInfo) {
            return true;
        }
    }
    
    if ((level & SHBLogLevelWarning) != 0) {
        if (type == SHBLogTypeWarning) {
            return true;
        }
    }
    
    if ((level & SHBLogLevelError) != 0) {
        if (type == SHBLogTypeError) {
            return true;
        }
    }
    
    return false;
}

+ (void)setColor:(UIColor *)color forType:(SHBLogType)type {
    LogManager *manager = [LogManager sharedInstance];
    [manager.colorDic setObject:color forKey:SHBLogTypeString(type)];
}

+ (void)setColorEnabled:(BOOL)enabled {
    [LogManager sharedInstance].colorEnabled = enabled;
}


- (NSString *)currentLogPath
{
    return _filePath;
}

- (NSString *)documentPath:(NSString *)directory {
    NSString *docu = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject];
    
    if (directory.length == 0)
    {
        return docu;
    }
    NSString *localPath = [docu stringByAppendingPathComponent:directory];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:localPath])
    {
        [fileManager createDirectoryAtPath:localPath withIntermediateDirectories:true attributes:nil error:nil];
    }
    return localPath;
}

- (void)logMessage:(NSString *)aMessage fontColor:(UIColor *)aFontColor backgroundColor:(UIColor *)aBackgroundColor {
    
    NSString *logMsg = aMessage;
    NSUInteger msgLen = [logMsg lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    
    const BOOL useStack = msgLen < (1024 * 4);
    
    char msgStack[useStack ? (msgLen + 1) : 1]; // Analyzer doesn't like zero-size array, hence the 1
    char *msg = useStack ? msgStack : (char *)malloc(msgLen + 1);
    
    if (msg == NULL) {
        return;
    }
    
    BOOL logMsgEnc = [logMsg getCString:msg maxLength:(msgLen + 1) encoding:NSUTF8StringEncoding];
    
    if (!logMsgEnc) {
        if (!useStack && msg != NULL) {
            free(msg);
        }
        
        return;
    }

    
    int count = 5;
    
    struct iovec v[count];
    
    NSString *fColor = [self fgColor:aFontColor];
    NSString *gColor = [self bgColor:aBackgroundColor];
    
    NSUInteger fLen = [fColor lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger gLen = [gColor lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    

    const BOOL fuseStack = fLen < (1024 * 4);
    char fmsgStack[fuseStack ? (fLen + 1) : 1]; // Analyzer doesn't like zero-size array, hence the 1
    char *fc = fuseStack ? fmsgStack : (char *)malloc(fLen + 1);
    
    if (fc == NULL) {
        return;
    }
    
    BOOL flogMsgEnc = [fColor getCString:fc maxLength:(fLen + 1) encoding:NSUTF8StringEncoding];
    
    if (!flogMsgEnc) {
        if (!fuseStack && fc != NULL) {
            free(msg);
        }
        return;
    }
    
    const BOOL guseStack = gLen < (1024 * 4);
    char gmsgStack[guseStack ? (gLen + 1) : 1]; // Analyzer doesn't like zero-size array, hence the 1
    char *gc = guseStack ? gmsgStack : (char *)malloc(gLen + 1);
    
    if (gc == NULL) {
        return;
    }
    
    BOOL glogMsgEnc = [gColor getCString:gc maxLength:(gLen + 1) encoding:NSUTF8StringEncoding];
    
    if (!glogMsgEnc) {
        if (!guseStack && gc != NULL) {
            free(msg);
        }
        return;
    }
    
    if (self.colorEnabled) {
        v[0].iov_base = fc;
        v[0].iov_len = fLen;
        
        v[1].iov_base = gc;
        v[1].iov_len = gLen;
        
        v[4].iov_base = "\x1b[;";
        v[4].iov_len = 3;
    } else {
        v[0].iov_base = "";
        v[0].iov_len = 0;
        
        v[1].iov_base = "";
        v[1].iov_len = 0;
        
        v[4].iov_base = "";
        v[4].iov_len = 0;
    }
    
    v[2].iov_base = (char *)msg;
    v[2].iov_len = msgLen;
    
    v[3].iov_base = "\n";
    v[3].iov_len = (msg[msgLen] == '\n') ? 0 : 1;
    
    writev(STDOUT_FILENO, v, count);
}

- (NSString *)fgColor:(UIColor *)color {
    if (color == nil) {
        return @"";
    }
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    NSString *str = [NSString stringWithFormat:@"\x1b[fg%.f,%.f,%.f;", red * 255, green * 255, blue * 255];
    return str;
}

- (NSString *)bgColor:(UIColor *)color {
    if (color == nil) {
        return @"";
    }
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    NSString *str = [NSString stringWithFormat:@"\x1b[bg%.f,%.f,%.f;", red * 255, green * 255, blue * 255];
    return str;
}

- (BOOL)colorEnabled {
    
    char *xcode_colors = getenv("XcodeColors");
    if (xcode_colors && (strcmp(xcode_colors, "YES") == 0))
    {
        // XcodeColors is installed and enabled!
        setenv("XcodeColors", "YES", 0);
        
        return _colorEnabled;
    }
    return false;
}

@end
