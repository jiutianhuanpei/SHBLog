//
//  LogManager.m
//  Test
//
//  Created by shenhongbang on 16/8/4.
//  Copyright © 2016年 中移(杭州)信息技术有限公司. All rights reserved.
//

#import "LogManager.h"

#define XCODE_COLORS_ESCAPE @"\033["
#define XCODE_COLORS_RESET_FG  XCODE_COLORS_ESCAPE @"fg;"
#define XCODE_COLORS_RESET_BG  XCODE_COLORS_ESCAPE @"bg;"
#define XCODE_COLORS_RESET     XCODE_COLORS_ESCAPE @";"



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

void SHBLog(NSString *mat, ...) {
    va_list args;
    va_start(args, mat);
    NSString *message = [[NSString alloc] initWithFormat:mat arguments:args];
    va_end(args);
    [LogManager logType:SHBLogTypeNormal message:message];
}


void SHBInfoLog(NSString *mat, ...) {
    va_list args;
    va_start(args, mat);
    NSString *message = [[NSString alloc] initWithFormat:mat arguments:args];
    va_end(args);
    
    [LogManager logType:SHBLogTypeInfo message:message];
}

void SHBWarnLog(NSString *mat, ...) {
    va_list args;
    va_start(args, mat);
    NSString *message = [[NSString alloc] initWithFormat:mat arguments:args];
    va_end(args);
    
    [LogManager logType:SHBLogTypeWarning message:message];
}

void SHBErrorLog(NSString *mat, ...) {
    va_list args;
    va_start(args, mat);
    NSString *message = [[NSString alloc] initWithFormat:mat arguments:args];
    va_end(args);
    
    [LogManager logType:SHBLogTypeError message:message];
}



@interface LogManager ()

@property (nonatomic, assign) SHBLogLevel   level;

@property (nonatomic, strong) NSMutableDictionary   *colorDic;
@property (nonatomic, copy) NSString  *filePath;

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
        manager.filePath = [manager createLocalFile];
    });
    return manager;
}

+ (void)setLogLevel:(SHBLogLevel)level {
    [LogManager sharedInstance].level = level;
}

// 不同的 log type
+ (void)logType:(SHBLogType)type message:(NSString *)aMessage {
    LogManager *manager = [LogManager sharedInstance];
    
    UIColor *color = manager.colorDic[SHBLogTypeString(type)];
    if (color == nil) {
        color = [UIColor blackColor];
    }
    
    if (![self canLog:type]) {
        // 不在控制台输出
        return;
    }
    
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
    
    NSString *message = [NSString stringWithFormat:@"%@%@", prix, aMessage];
    
    NSString *colorString = [self fgStringWithColor:color];
    
    char *xcode_colors = getenv("XcodeColors");
    if (xcode_colors && (strcmp(xcode_colors, "YES") == 0))
    {
        setenv("XcodeColors", "YES", 0);
        // XcodeColors is installed and enabled!
        NSLog((XCODE_COLORS_ESCAPE @"%@" @"%@" XCODE_COLORS_RESET), colorString, message);
    }
    else
    {
        NSLog(@"%@", message);
    }
    
    /**
     *  不同打印type的前缀
     */
    static NSDateFormatter *df = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    });
    
    NSString *time = [NSString stringWithFormat:@"[%@] ", [df stringFromDate:[NSDate date]]];

    message = [time stringByAppendingString:message];
    
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

+ (NSString *)fgStringWithColor:(UIColor *)color {
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    NSString *str = [NSString stringWithFormat:@"fg%.f,%.f,%.f;", red * 255, green * 255, blue * 255];
    return str;
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

@end
