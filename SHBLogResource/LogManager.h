//
//  LogManager.h
//  Test
//
//  Created by shenhongbang on 16/8/4.
//  Copyright © 2016年 中移(杭州)信息技术有限公司. All rights reserved.
//

/**
 *  设置：如果安装了 XcodeColors 插件，可以开启不同颜色日志，按如下配置
 *  Edit Scheme -> Run -> Environment Variables
 *  添加 XcodeColors : YES
 *
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 控制台打印级数
typedef NS_ENUM(NSInteger, SHBLogLevel) {
    SHBLogLevelAll = 1,
    SHBLogLevelInfo = 1 << 1,
    SHBLogLevelWarning = 1 << 2,
    SHBLogLevelError = 1 << 3,
    SHBLogLevelNone = 1 << 4,
};

// Log 的样式
typedef NS_ENUM(NSInteger, SHBLogType) {
    SHBLogTypeNormal,
    SHBLogTypeInfo,
    SHBLogTypeWarning,
    SHBLogTypeError,
};

#define SHBLog(mat, ...) [LogManager logType:SHBLogTypeNormal message:mat, ##__VA_ARGS__]
#define SHBInfoLog(mat, ...) [LogManager logType:SHBLogTypeInfo message:mat, ##__VA_ARGS__]
#define SHBWarnLog(mat, ...) [LogManager logType:SHBLogTypeWarning message:mat, ##__VA_ARGS__]
#define SHBErrorLog(mat, ...) [LogManager logType:SHBLogTypeError message:mat, ##__VA_ARGS__]

#if DEBUG
#define SHBMyLog(mat, ...) NSLog((@"MyLog: "mat), ##__VA_ARGS__)
#else
#define SHBMyLog(...)
#endif

@interface LogManager : NSObject

+ (LogManager *)sharedInstance;

/**
 *  设置显示的级别
 */
+ (void)setLogLevel:(SHBLogLevel)level;

/**
 *  为不同的log添加颜色
 *
 *  默认 Info:浅蓝   Error:红色   warning:橘色
 *  @param color 颜色
 *  @param type  log的type
 */
+ (void)setColor:(UIColor *)color forType:(SHBLogType)type;

/**
 *  是否允许开启颜色, 默认开启
 */
+ (void)setColorEnabled:(BOOL)enabled;

/**
 *  是否把日志写入本地，默认不写入
 */
+ (void)enableWriteFileToLocal:(BOOL)enabled;

/**
 *  打印
 *
 *  @param type     log type
 *  @param aMessage 消息
 */
+ (void)logType:(SHBLogType)type message:(NSString *)aMessage, ...;

/**
 *  当前log文件地址
 */
@property (nonatomic, readonly, copy) NSString *currentLogPath;

@end
